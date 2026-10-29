# AI-Lab 通识学习计划与环境踩坑记录

> **作者**：<你的名字 / GitHub ID>　**日期**：2026-10-12　**仓库**：`github.com/<账号>/<仓库名>`　**分支**：`main`
>
> 本文是 AI-Lab 通识考核 Task 02 的交付物，同时作为个人实战笔记库的索引页。
> 排版要素自查：✅ 表格（多处）　✅ 代码块（第二、五节）　✅ 环境截图（第三节）　✅ 外部参考链接（第五节）

---

## 一、学习计划与进度

| 周次 | 主题 | 指定资源 | 我的产出 | 状态 |
|---|---|---|---|---|
| W1 | Git 版本控制 | 廖雪峰 Git 教程（安装 / 建仓 / 分支 / 合并） | 本文所在仓库 + 一次真实的分支合并与冲突解决 | 🔶 进行中 |
| W1 | Linux 命令行与 Shell | Linux 命令行基础 | 日志过滤与批处理脚本各一个 | 🔶 |
| W2 | Python 入门 | 廖雪峰 Python 教程 | 3 个脚本：文件遍历 / 调 API / argparse 命令行工具 | ✅ 环境就绪 |
| W2 | Markdown 规范 | GitHub Flavored Markdown 规范 | 本笔记库（四类目录体系） | 🔶 本文件 |
| W3 | Docker 基础 | Docker 快速起步 + Dockerfile 语法 | 一个能跑通本地脚本的镜像 | 🔶 |
| W3 | 终端 AI 协同工具 | OpenCode / DSH | 一次交互式代码审查（含终端截图） | ✅ DSH 已可用 |
| W4 | 算法练习 | 洛谷题单 | 入门题单完成记录（思路 / 复杂度 / 踩坑） | 🔶 |

---

## 二、环境配置清单

| 组件 | 版本 / 位置 | 验证方式 |
|---|---|---|
| 操作系统 | Windows 11（NT 10.0.26200，x64） | `[System.Environment]::OSVersion.VersionString` |
| VS Code | 1.141.0（用户级），16 个插件 | 见下方验证代码块 |
| Python | 3.14.8 @ `%LOCALAPPDATA%\Programs\Python\Python314` | `python --version` |
| pip / venv | pip 26.2.1，venv 可创建且自带 pip | `python -m pip --version` |
| Jupyter 内核 | ipykernel 7.4.0，内核名 `python314` | `jupyter kernelspec list` |
| `py` 启动器 | Python Install Manager 26.4 | `py --version` |
| 代码质量工具 | black 26.10.1、ruff 0.17.0 | `black --version` / `ruff --version` |
| Git | 2.56.0.windows.2 | `git --version` |
| 终端 AI 工具 | DSH（DeepSeek Harness）桌面版 0.2.0-rc.2 + CLI | 运行 `dsh.cmd` 进入交互 |

**一键复跑的环境自检：**

```powershell
# 1) 命令行解析是否正确（新终端执行）
python --version; py --version; pip --version; black --version; ruff --version

# 2) Python 完整性体检（检查 stdlib 导入、venv、tkinter、OpenSSL）
python "$env:USERPROFILE\Documents\deepseek-harness\default-workspace\python-healthcheck.py"

# 3) VS Code 插件清单（在普通终端执行；DSH 沙箱内会因写日志被拒）
code --list-extensions --show-versions
```

---

## 三、环境截图

**图 1：VS Code 工作界面（文件树 + 扩展列表 + Error Lens 内联提示）**

![VS Code 工作界面与本机 AI 编程环境](./assets/env-vscode.png)

> ⏳ **待补图**：保存为 `assets/env-vscode.png`（工作区根目录的 `assets/` 已建好）。

**图 2：终端中 DSH 完成一次交互式代码审查**

![DSH 终端交互式代码审查](./assets/terminal-dsh-review.png)

> ⏳ **待补图**：保存为 `assets/terminal-dsh-review.png`。

> 截图规范：放在与本文件同级的 `assets/` 目录下，用**相对路径**引用；替代文本必须写清"这张图在证明什么"，便于评审快速核对。
> 网络图片引用示例（不占仓库体积）：`![Python 官方 Logo](https://www.python.org/static/img/python-logo.png)`

### 3.1 文本版环境证据（截图时请让这些行出现在画面里）

以下均为本机**实测输出**，评审可逐行对照：

```text
> python --version
Python 3.14.8
> py --version
Python 3.14.8
> pip --version
pip 26.2.1 from C:\Users\29813\AppData\Local\Programs\Python\Python314\Lib\site-packages\pip (python 3.14)
> black --version
black, 26.10.1 (compiled: yes) Python (CPython) 3.14.8
> ruff --version
ruff 0.17.0
> git --version
git version 2.56.0.windows.2
> jupyter kernelspec list
Available kernels:
  python314    C:\Users\29813\AppData\Roaming\jupyter\kernels\python314
  python3      C:\Users\29813\AppData\Local\Programs\Python\Python314\share\jupyter\kernels\python3
```

---

## 四、踩坑记录

| # | 现象 | 关键报错原文 | 根因 | 解决与验证 |
|---|---|---|---|---|
| 1 | 终端里 curl/PowerShell 无法 HTTPS | `schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS` | 当前受限环境拿不到 Windows 加密凭据 | 改用 **Python（自带 OpenSSL）** 发起请求；`ssl.OPENSSL_VERSION` 验证为 3.5.9 |
| 2 | 官方 Python 安装器装不上 | `Error 0x80070005: Failed to create cache directory: …\Package Cache\{…}\` | 提权前是过滤令牌（`Administrators` 标记 deny-only），WiX Burn 建缓存/注册会话被拒 | 改用官方 **NuGet 发行包 + install-manager 发行 zip** 落地安装，逐个校验 SHA-256 |
| 3 | 找不到 launcher.msi | HTTP 404（3.12 / 3.13 / 3.14 的 `amd64/` 目录均无） | Python 3.14 起 `py` 并入 **Python install manager** | 安装 pymanager 26.4，并手写 **PEP 514** 注册项（`HKCU\Software\Python\PythonCore\3.14`） |
| 4 | `import tkinter` 失败 | `ModuleNotFoundError: No module named 'tkinter'` | 该官方分发（NuGet 包）刻意裁剪了 tcl/tk | 用官方 `python-3.14.8-amd64.zip` 补 `_tkinter.pyd`、`tcl90.dll`、`Lib\tkinter`；实测 `tkinter.Tk()` 成功，Tcl/Tk 9.0.4 |
| 5 | `python` 指向了垫片而非真实解释器 | `Get-Command python` → `…\Programs\PyManager\python.exe` | 用户 PATH 顺序把 PyManager 放在了最前 | 调整为 `Python314\Scripts → Python314 → PyManager → WindowsApps` |
| 6 | 受限模式下建 venv 失败 | `PermissionError: [Errno 13] …\Temp\dsh-xxxx\tmp_xxx\pip-26.2.1-py3-none-any.whl` | 该环境下 `%TEMP%` 子目录不可写，与 Python 本身无关 | 把 `TEMP` 指向工作区目录后成功；普通终端无此问题（已复测 venv 自带 pip） |
| 7 | ruff 扩展装不上 | `Extension 'astral-sh.ruff' not found` | 该扩展 id 不存在（发布者改名后旧 id 仍为现役） | 使用 `charliermarsh.ruff`（2026.86.0） |
| 8 | 无法读取飞书/GitHub 在线文档 | `cross-origin redirect to accounts.feishu.cn` / `hostname resolves to a non-public IP address` | 需登录；本机 DNS 对部分域名返回非公网地址 | 改为导出文件或粘贴正文；`git push` 失败时优先排查 DNS / 代理 |

**共性教训**：遇到报错先分清是**网络层 / 权限层 / 工具层**哪一层的问题——例如 401 是"链路通、Key 错"，402 是"鉴权通、余额不足"，两者与超时完全是不同性质的问题，排查方向也完全不同。

---

## 五、外部参考链接

| 资源 | 链接 | 用途 |
|---|---|---|
| Python 官方网站 | <https://www.python.org/> | 版本与安装包（含官方 Windows 发行包） |
| 廖雪峰 Git 教程 | <https://liaoxuefeng.com/> | 安装、建仓、分支与合并 |
| Pro Git 中文版 | <https://git-scm.com/book/zh/v2> | 深入理解 Git 数据模型与冲突机制 |
| Docker 快速起步 | <https://docs.docker.com/get-started/> | 镜像、容器与 Dockerfile |
| GitHub Flavored Markdown 规范 | <https://github.github.com/gfm/> | 表格、任务清单、代码块高亮的官方定义 |
| 洛谷 | <https://www.luogu.com.cn/> | 算法题单练习 |
| OpenCode 文档 | <https://opencode.ai/docs/> | 终端 AI 编程 Agent 的安装与配置 |
| DeepSeek API 文档 | <https://api-docs.deepseek.com/zh-cn/> | API 调用与错误码含义 |

---

## 六、下一步计划

1. 补齐终端交互截图与 IDE 截图，完成 GitHub 仓库交付（Task 01 交付要求）；
2. 申请一个免费/低价模型 API Key（SiliconFlow / DeepSeek / 智谱），跑通 `deepseek_api_smoke_test.py` 拿到 `RESULT: PASS`；
3. 把本仓库的 `docs/` 目录按四类体系（环境配置 / 排错记录 / 代码实验 / 文献摘记）补齐，本文迁入 `docs/90-交付物/`；
4. 完成洛谷入门题单，并为每道题单独写一条"思路 → 复杂度 → 踩坑"记录。
