# PowerShell 5.1 写配置文件产生 BOM，导致 JSON 解析失败

> 日期：2026-10-17　环境：Windows 11 + 系统自带 Windows PowerShell 5.1.26100

## 现象

用脚本修改 VS Code 的 `settings.json`（含中文注释）后，后续校验报：

```
JSONC 校验失败: 无效的 JSON 基元: 。
```

同时在 UI 里表现为设置不生效。文件字节数确实变大了，说明"写进去了"，但内容不可用。

## 关键报错 / 观测

1. 检查文件头三字节：`239,187,191` → 这是 **UTF-8 BOM**（`EF BB BF`）。
2. 检查 shell 版本：`$PSVersionTable.PSVersion` = **5.1**。
3. 旁证：脚本里用了 `Get-Content -AsByteStream`，报"找不到与参数名称匹配的参数"——该参数是 PowerShell **6+** 才有的。

## 根因

在 Windows PowerShell 5.1 下：

- `Set-Content -Encoding utf8` 写入的是 **UTF-8 with BOM**（7.x 才默认无 BOM）；
- `Get-Content -Raw` 的默认解码是**系统 ANSI/GBK**，读 UTF-8 中文会把注释读成乱码，再写回时乱码被"固化"。

两个问题叠加：文件既有 BOM（`ConvertFrom-Json` 无法解析首字符），中文注释也被破坏。

## 解决

改用 .NET API 显式指定"UTF-8 无 BOM"，并避免用 `Get-Content -Raw` 读再写回：

```powershell
# 写：UTF-8 无 BOM
[System.IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding($false)))

# 读：显式 UTF-8
$text = [System.IO.File]::ReadAllText($path)

# 校验：去掉 // 注释后用 ConvertFrom-Json
$obj = [regex]::Replace($text, '(?m)^\s*//.*$', '') | ConvertFrom-Json
```

## 验证

| 检查项 | 命令 | 期望 |
|---|---|---|
| 无 BOM | `(Get-Content $p -Encoding Byte -TotalCount 3) -join ','` | `123,10,32`（`{` + 换行 + 空格） |
| 可解析 | 去注释后 `ConvertFrom-Json` | 成功，54 个顶层键 |
| 中文完好 | `$text -match '编辑器通用'` | `True` |

## 教训（可迁移）

> 只要涉及"脚本改配置文件"，先确认**运行时版本**，再确认**编码与 BOM**。
> 判断依据不要靠猜：`$PSVersionTable` 一眼可查；某个参数报"不存在"时，八成是版本差异，而不是拼写问题。
