# Task 04 交付：Git 版本管理规范与 GitHub 协作实操

> 执行日期：2026-10-17　环境：Windows 11 + **Git 2.56.0.windows.2**（Git Bash）
> 演示仓库：`~/ailab/task04`　执行结果：**全流程跑通**（init → commit → 分支 → 快进合并 → 冲突 → 解决 → 远程配置）
> 标注：✅ **实测**（本机真实执行，输出为原文）　🟡 **待你执行**（需 GitHub 账号，我做不了）

---

## 一、环境与前置状态

```text
git version 2.56.0.windows.2
工作目录: /c/Users/29813/ailab/task04
--- 全局身份配置 ---
user.email=2981364052@qq.com
user.name=张泽川
```

✅ 结论：**第 1 步的本地身份配置已经完成**（`git config --global user.name/user.email` 已就位），不需要再配。

---

## 二、第 1 步：账号与 SSH Key（🟡 待你执行）

本地身份已配好，还差 **SSH Key 生成 + 上传到 GitHub**：

```bash
# 1) 生成密钥（ed25519，比 RSA 更短更安全）
ssh-keygen -t ed25519 -C "2981364052@qq.com"
# 连按三次回车：默认路径 ~/.ssh/id_ed25519、不设 passphrase（个人机可接受）

# 2) 启动 ssh-agent 并加入密钥（每次新开终端要重做，或写进 ~/.bashrc）
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 3) 复制公钥（注意是 .pub，不是私钥！）
cat ~/.ssh/id_ed25519.pub
```

GitHub 网页侧：`Settings` → `SSH and GPG keys` → `New SSH key` → 粘贴上一步输出 → 保存。

验证：

```bash
ssh -T git@github.com
# 期望：Hi <你的用户名>! You've successfully authenticated, but GitHub does not provide shell access.
```

> ⚠️ **本机已知风险**：之前实测过，`github.com` 在本机的域名解析会返回**非公网地址**（抓取器直接拒绝）。所以 `ssh -T` 或 `git push` 若卡住/报 `Could not resolve host`，**先查 DNS 与代理**，不要反复重试。

---

## 三、第 2 步：本地版本库管理（✅ 全部实测）

### 3.1 建库 + 首次提交

```bash
git init -b main
git status --short
git add README.md .gitignore
git status --short
git commit -m "chore: 初始化仓库，添加 README 与 .gitignore"
git log --oneline
```

真实输出：

```text
?? .gitignore
?? README.md
A  .gitignore
A  README.md
[main (root-commit) 50bf779] chore: 初始化仓库，添加 README 与 .gitignore
 2 files changed, 5 insertions(+)
50bf779 chore: 初始化仓库，添加 README 与 .gitignore
```

**读懂 `status --short` 的两列**：`??` 未跟踪、`A ` 已暂存（第一列=暂存区，第二列=工作区）。

### 3.2 `.gitignore` 生效验证

```bash
printf '*.log\n' > .gitignore
printf 'ERROR 不应被跟踪\n' > debug.log
git status --short        # debug.log 不出现在输出里 = 被忽略 ✅
```

### 3.3 提交信息规范（本仓库统一采用 Conventional Commits）

| 前缀 | 含义 | 本次实例 |
|---|---|---|
| `feat:` | 新功能 | `feat(notes): 添加 notes.txt` |
| `fix:` | 修 bug | — |
| `chore:` | 杂务/初始化 | `chore: 初始化仓库…` |
| `docs:` | 文档 | — |
| `merge:` | 合并提交 | `merge: 解决 conflict.txt 冲突…` |

格式：`类型(范围): 祈使句描述`，**不超过 50 字、结尾不加句号、一条提交只做一件事**。

---

## 四、第 3 步：分支与合并流（✅ 全部实测）

### 4.1 建分支 + 快进合并

```bash
git checkout -b feature/greeting     # 建分支并切换（等价 git branch + git switch）
# …改动并提交…
git branch -vv                        # 看分支与各自指向的提交
git checkout main
git merge feature/greeting            # 快进合并
```

真实输出：

```text
Switched to a new branch 'feature/greeting'
* feature/greeting 2e09faf feat(notes): 追加问候语
  main             f74b09c feat(notes): 添加 notes.txt
Updating f74b09c..2e09faf
Fast-forward
 notes.txt | 1 +
```

**要点**：`Fast-forward` 表示 main 没有新提交，于是直接把指针前移 —— **不产生 merge 提交节点**。历史图仍是直线：

```text
* 2e09faf feat(notes): 追加问候语
* f74b09c feat(notes): 添加 notes.txt
* 50bf779 chore: 初始化仓库，添加 README 与 .gitignore
```

### 4.2 冲突现场（两个分支改同一文件）

```bash
git checkout -b feature/conflict
printf 'from feature\n' > conflict.txt
git add conflict.txt && git commit -m "feat: feature 侧的 conflict.txt"

git checkout main
printf 'from main\n' > conflict.txt
git add conflict.txt && git commit -m "feat: main 侧的 conflict.txt"

git merge feature/conflict
```

真实输出：

```text
Auto-merging conflict.txt
CONFLICT (add/add): Merge conflict in conflict.txt
Automatic merge failed; fix conflicts and then commit the result.
merge 退出码: 1（非 0 表示有冲突）
```

`git status --short` 显示：

```text
AA conflict.txt
```

> 注意：这里是 **`AA`（add/add，两边都新建了同名文件）**，不是常见的 `UU`（both modified）。**状态码会随场景变化**，别死记一个。

冲突文件内容（Git 插入了标记）：

```text
<<<<<<< HEAD
from main
=======
from feature
>>>>>>> feature/conflict
```

### 4.3 解决冲突的三步法

```bash
# ① 编辑文件，删掉 <<<<<<< ======= >>>>>>> 三行标记，留下你要的内容
printf 'from main\nfrom feature\n' > conflict.txt

# ② 标记为已解决
git add conflict.txt

# ③ 提交（此时才真正完成合并）
git commit -m "merge: 解决 conflict.txt 冲突，保留双方内容"
```

解决后的历史图（出现真正的分叉与汇合）：

```text
*   319fd0e merge: 解决 conflict.txt 冲突，保留双方内容
|\
| * 061985b feat: feature 侧的 conflict.txt
* | af0fd8c feat: main 侧的 conflict.txt
|/
* 2e09faf feat(notes): 追加问候语
* f74b09c feat(notes): 添加 notes.txt
* 50bf779 chore: 初始化仓库，添加 README 与 .gitignore
```

**记住**：冲突解决完**必须 `git add` + `git commit`**，否则仓库一直停在 `MERGING` 状态，后续操作会报 "You have not concluded your merge"。

---

## 五、第 4 步：远程仓库交互（🟡 待你执行，命令已备好）

```bash
# 0) 先在 GitHub 网页端建一个空仓库（不要勾选 Add README，避免首推冲突）

# 1) 关联远程（SSH 方式，配合第 1 步的 Key）
git remote add origin git@github.com:你的用户名/你的仓库.git
git remote -v

# 2) 首次推送（-u 建立上游跟踪，之后直接 git push 即可）
git push -u origin main

# 3) 日常往返
git pull            # 拉取并合并
git clone git@github.com:你的用户名/你的仓库.git   # 换机器时
```

> ⚠️ **真实踩坑（我脚本里就犯了）**：写 `git remote add origin https://github.com/<你的账号>/<仓库>.git` 时，shell 会把 `<`、`>` 当成**输入/输出重定向**，报 `你的账号: No such file or directory`。
> 正确做法：**换成不含尖括号的占位符并加引号** —— `git remote add origin "https://github.com/USERNAME/REPO.git"`。

HTTPS 与 SSH 的区别：

| 方式 | 优点 | 缺点 |
|---|---|---|
| HTTPS | 免配置、跨网络穿透好 | 每次要输 token；不能免密（除非配凭据管理器） |
| SSH | 配好后免密、更安全 | 要先传公钥；22 端口被墙时需换 443 |

---

## 六、常见坑清单（Windows 环境尤其注意）

| 坑 | 现象 | 处理 |
|---|---|---|
| **CRLF 警告** | `warning: LF will be replaced by CRLF` | Git for Windows 默认 `core.autocrlf=true`；跨平台协作建议 `git config --global core.autocrlf input` 并加 `.gitattributes` |
| 尖括号被当重定向 | `<你的账号>: No such file or directory` | 占位符**不要用 `<>`**，或整体加引号 |
| 冲突后忘了 commit | `You have not concluded your merge` | `git add` + `git commit` 才结束合并 |
| 先建了带 README 的远程仓库 | `git push` 被拒（non-fast-forward） | 先 `git pull --rebase origin main` 再推，或建空仓库 |
| `git add .` 误收垃圾 | 提交里混进日志/依赖目录 | 先写 `.gitignore`，再 `git add` |
| 提交信息写成"更新""修改" | 历史无法回溯 | 用约定的类型前缀 + 说明"做了什么、为什么" |
| 在错误分支提交 | 提交跑到 main | 立刻 `git branch feature/x`（把当前提交挪到新分支）再 `git reset --hard HEAD~1` |

---

## 七、截图（🟡 待补）

**图 1：本地提交历史图**

![git log --oneline --graph --all 的真实输出](./assets/task04-git-log.png)

> ⏳ 在本节命令跑完后，执行 `git log --oneline --graph --all` 截图，保存为 `assets/task04-git-log.png`。

**图 2：冲突与解决过程**

![冲突标记与解决后的提交](./assets/task04-merge-conflict.png)

> ⏳ 冲突发生时 `cat conflict.txt` 与 `git status --short` 同一屏截图，保存为 `assets/task04-merge-conflict.png`。

---

## 八、怎么复现（一条命令）

本机已备好演示脚本，在 Git Bash 里执行即可看到与本文完全一致的流程（含冲突）：

```bash
bash /c/Users/29813/Documents/deepseek-harness/default-workspace/task04-git-demo.sh
```

脚本会重建 `~/ailab/task04`，**不触碰全局配置、不推送任何东西**。

---

## 九、自检表

| 检查项 | 期望 | 本次结果 |
|---|---|---|
| 全局身份是否已配置 | `git config --global user.name` 有值 | ✅ `张泽川` |
| SSH Key 是否已上传 GitHub | `ssh -T git@github.com` 返回 Hi … | 🟡 待执行 |
| 能建库并完成首次提交 | `git log --oneline` 有 1 条 | ✅ `50bf779` |
| `.gitignore` 生效 | 被忽略文件不出现在 `status` | ✅ |
| 能建分支并快进合并 | 出现 `Fast-forward` | ✅ |
| 能制造并解决冲突 | 有 `CONFLICT` + 解决后 merge 节点 | ✅ `AA` → `319fd0e` |
| 远程交互 | `git push -u origin main` 成功 | 🟡 待执行 |
| 提交信息规范 | 全部带类型前缀 | ✅ `chore/feat/merge` |

---

## 附：产物

| 文件 | 说明 |
|---|---|
| `task04-git-demo.sh` | 完整演示脚本（可重复执行） |
| `task04-demo-output.txt` | 本次真实执行输出（UTF-8 原文） |
| `~/ailab/task04` | 演示仓库本体（含 6 个提交、3 个分支） |
