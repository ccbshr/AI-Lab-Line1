# WSL2 安装与配置指南（Windows 11 · 26200）

> 适用本机：Win11 NT 10.0.26200 x64。目标：拿到一个可用的 Ubuntu 环境，供 AI-Lab「Linux 命令行与 Shell 脚本」任务使用。

## 0. 为什么有一条命令必须你亲手执行

| 事实 | 证据 |
|---|---|
| 我的会话**不是**管理员 | `whoami /groups` → `BUILTIN\Administrators … Group used for deny only`，完整性级别 `Medium` |
| 启用 WSL 功能需要管理员 | `wsl --install` / `dism /online` 都要提权 |
| 我无法自行 UAC 提权 | 提权是交互式的，需要你在弹窗里点"是" |

**结论**：第 2 节那条管理员命令由你执行；第 3 节之后（换源、systemd、.wslconfig、VS Code 集成、git）由我接手。

---

## 1. 前置检查（普通终端即可，先跑这个）

```powershell
wsl --status
wsl -l -v
systeminfo | Select-String 'Hyper-V'
```

判读：

| 输出 | 含义 | 下一步 |
|---|---|---|
| `wsl --status` 正常、`wsl -l -v` 里有 `VERSION 2` | 已装好 WSL2 | 跳到第 4 节验证 |
| `wsl -l -v` 报"没有已安装的分发" | WSL 内核在、缺发行版 | 走第 2 节（只需装发行版） |
| `wsl` 不是命令 / `wsl --status` 报错 | 功能没启用 | 走第 2 节（含启用组件） |

---

## 2. 安装（**管理员终端**）

**打开方式**：`Win + X` → 点「**终端(管理员)**」（或「Windows PowerShell(管理员)」）→ UAC 弹窗点"**是**"。

先确认窗口标题带「管理员」字样，然后：

```powershell
wsl --install -d Ubuntu-24.04
```

预期：出现「正在安装: 虚拟机平台 / 正在安装: Windows 用于 Linux 的子系统」→ 下载 Ubuntu → 最后提示**需要重启**。

重启后 Ubuntu 会自动启动，要求设置**用户名**和**密码**（密码输入时不回显，属正常）。

### 如果 `wsl --install` 失败

先试更新 WSL 本体：

```powershell
wsl --update
```

仍失败就手动启用两个必需组件（**同样需要管理员窗口**）：

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

然后**重启**，再执行 `wsl --install -d Ubuntu-24.04`。

> 注：`VirtualMachinePlatform` 是 WSL2 的硬依赖（它用 Hyper-V 的轻量虚拟化）。若该组件启用失败，先检查安全软件（火绒/360/Defender 篡改防护）是否拦截了系统功能变更。

---

## 3. 重启后的第一件事：确认默认版本

```powershell
wsl --set-default-version 2
wsl --status
wsl -l -v
```

期望 `wsl -l -v` 里 `VERSION` 列为 **2**。若显示 1：

```powershell
wsl --set-version Ubuntu-24.04 2
```

---

## 4. 验证清单（**把这些输出贴给我**）

Windows 侧：

```powershell
wsl -l -v
wsl --status
```

WSL 内（进入 WSL 后执行，命令是 `wsl` 或直接点开始菜单里的 Ubuntu）：

```bash
cat /etc/os-release | head -3
uname -r
nproc
free -h
df -h /
```

判读要点：`VERSION 2`、`uname -r` 带 `microsoft-standard-WSL2` 字样、`df -h /` 有足够空间（默认给的是虚拟磁盘，上限约 1 TB，按需增长）。

---

## 5. 我接下来会配的（等你确认装好后）

| 项 | 做什么 | 为什么 |
|---|---|---|
| `/etc/wsl.conf` | 开 `systemd=true`、关 Windows PATH 注入 | 让 `systemctl` 可用；避免 Linux 里出现一堆 Windows 路径 |
| `%USERPROFILE%\.wslconfig` | 限制内存/CPU、开镜像网络 | 防止 WSL 吃掉全部内存；镜像网络让代理配置更简单 |
| apt 换源 | 换成国内镜像（清华/阿里） | 默认源在国内很慢，`apt update` 会等到超时 |
| 基础工具 | `git build-essential curl jq vim unzip` | 后续所有练习的前提 |
| git 身份 | `user.name` / `user.email` + SSH key | 若要往 GitHub 推仓库 |
| VS Code 集成 | 装 `ms-vscode-remote.remote-wsl` 扩展 | 在 WSL 里 `code .` 直接打开 Linux 文件系统，编辑体验和本地一致 |
| 练习目录 | `~/ailab/{scripts,notes}` | 对齐 AI-Lab 的 Linux 任务与笔记体系 |

---

## 6. 常见报错对照表

| 报错 | 原因 | 处理 |
|---|---|---|
| `WslRegisterDistribution failed with error: 0x8007019e` | 子系统功能未启用 | 第 2 节的手动启用 + 重启 |
| `0x80370102` / `Please enable the Virtual Machine Platform` | BIOS 里虚拟化没开，或组件未启用 | 进 BIOS 开 `VT-x`(Intel) / `SVM`(AMD)；再启用 `VirtualMachinePlatform` |
| `wsl --install` 长时间卡在下载 | 网络到 Microsoft 分发源慢 | 加 `--web-download`；或先 `wsl --update` 再装发行版 |
| `VirtualMachinePlatform` 启用失败 | 安全软件/组策略拦截 | 临时关闭篡改防护后重试 |
| Ubuntu 里 `apt update` 极慢或超时 | 默认源指向 archive.ubuntu.com | 换国内镜像（第 5 节） |
| `wsl` 命令存在但报 `WSL 2 requires an update to its kernel component` | 缺内核更新包 | `wsl --update` |
| 和 VirtualBox/VMware 冲突或变慢 | Hyper-V 与第三方虚拟化互斥 | 二选一；或用 VirtualBox 的 Hyper-V 兼容模式 |

---

## 7. 备选方案（若坚决不想提权）

| 方案 | 优点 | 代价 |
|---|---|---|
| 便携 QEMU + cloud image | 完全免管理员 | 无硬件加速时很慢；无 GUI 管理界面；需要自己写启动参数 |
| 云端 Linux（云服务器试用 / 在线沙箱） | 零本地安装 | 需要账号与联网；免费额度有限 |

对「Linux 命令行基础」这个目标，**WSL2 是投入产出比最高的选择**：与 VS Code 深度集成、启动快、不占独立磁盘映像。
