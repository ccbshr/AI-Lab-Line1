# 本机 AI 编程环境基线（Windows）

> 记录时间：2026-10-17　用途：换机器 / 重装后照着复现，或排查"为什么我这里跑不起来"。

## 一、组件清单

| 组件 | 版本 / 位置 | 为什么需要它 |
|---|---|---|
| 操作系统 | Windows 11（NT 10.0.26200，x64） | — |
| VS Code | 1.141.0，用户级安装 | 主工作台 |
| 扩展（Markdown 三件套） | All in One 3.6.3 / Preview Enhanced 0.8.40 / Paste Image 1.0.4 | 笔记书写 + 预览 + 截图入仓 |
| 扩展（Python 系） | Python 2026.8.0 / Pylance 2026.4.1 / Debugpy 2026.6.0 / Jupyter 2025.9.1 | 语言服务、调试、Notebook |
| Python | 3.14.8 @ `%LOCALAPPDATA%\Programs\Python\Python314` | 脚本与实验 |
| pip / venv | pip 26.2.1；venv 可创建且自带 pip | 依赖管理、隔离环境 |
| Jupyter 内核 | ipykernel 7.4.0（内核名 `python314`） | Notebook 执行 |
| `py` 启动器 | Python Install Manager 26.4 | 多版本切换 |
| 代码质量 | black 26.10.1 / ruff 0.17.0 | 保存即格式化 + Lint |
| Git | 2.56.0.windows.2 | 版本控制 |
| 终端 AI 工具 | DSH（DeepSeek Harness）桌面版 0.2.0-rc.2 + CLI | 交互式代码审查/解释/写脚本 |

## 二、一条命令复检全部

```powershell
# 1) 命令行工具链
python --version; py --version; pip --version; black --version; ruff --version; git --version

# 2) Python 完整性（stdlib 导入 / venv / tkinter / OpenSSL）
python "$env:USERPROFILE\Documents\deepseek-harness\default-workspace\python-healthcheck.py"

# 3) Jupyter 内核
jupyter kernelspec list

# 4) VS Code 扩展
code --list-extensions --show-versions | Select-String 'markdown|paste|python|jupyter'
```

期望：Python/`py` 都是 `3.14.8`；`kernelspec list` 里有 `python314`；扩展清单里能看到上面三件套。

## 三、环境截图

![VS Code 中打开本笔记库、并显示扩展面板的界面](./assets/env-vscode.png)

> ⏳ **待补图**：截一张"VS Code 打开 `docs/` 且左侧扩展面板可见"的图，保存为 `assets/env-vscode.png`（本目录的 `assets/` 已建好）。

## 四、关键设计决定（踩过坑后的结论）

1. **PATH 顺序**：`Python314\Scripts` → `Python314` → `PyManager` → `WindowsApps`。
   原因：PyManager 目录里有自己的 `python.exe` 垫片，放最前面会把 `python` 劫持走。
2. **PEP 514 注册**：`HKCU\Software\Python\PythonCore\3.14`。
   原因：让 `py` 启动器和 VS Code 都能自动发现解释器。
3. **settings.json 用 UTF-8 无 BOM 写入**。
   原因见 [排错记录](<../10-排错记录/2026-10-17-powershell5-写配置产生BOM.md>)。
4. **Markdown 只用一套预览**：保留 MPE，关闭 All in One 的自动侧栏预览。
   原因：两套预览同时开会产生两个面板，滚动同步也会互相抢。
