# Linux 命令行基础速查（对应 AI-Lab Task 03 a–d）

> 整理时间：2026-10-17　适用：Ubuntu 22.04/24.04（WSL2 或原生）
> 记法：每条命令给 **一句话作用 → 最小示例 → 最常踩的坑**。**读懂坑，比背参数值钱。**

---

## 0. 先建一个"随便造"的练习沙箱

所有练习都在这个目录里做，删错也不心疼：

```bash
mkdir -p ~/ailab/lab03 && cd ~/ailab/lab03
printf 'line1\nline2 ERROR\nline3 ERROR\n' > demo.log
mkdir -p data/sub && touch data/sub/{a,b,c}.txt
ls -R
```

---

## 1. 目录与文件操作（任务 a）

### 1.1 `pwd` — 我在哪

```bash
pwd            # /home/you/ailab/lab03
```

**坑**：脚本里依赖相对路径时，先 `cd "$(dirname "$0")"` 或显式用绝对路径，否则换个目录跑就崩。

### 1.2 `cd` — 换目录

```bash
cd /var/log      # 绝对路径
cd ..            # 上一级
cd -             # 回到上一个目录（来回跳，超好用）
cd ~             # 回家目录
cd               # 等价于 cd ~
```

**坑**：`cd` 是内建命令，**只在当前 shell 生效**；写脚本时不要指望它影响父进程。

### 1.3 `ls` — 看目录

| 参数 | 作用 |
|---|---|
| `-l` | 长格式（权限、属主、大小、时间） |
| `-a` | 含隐藏文件（`.` 开头） |
| `-h` | 人类可读大小（配合 `-l` 用） |
| `-t` | 按修改时间排序 |
| `-S` | 按大小排序 |
| `-r` | 反序 |
| `-R` | 递归 |

```bash
ls -lah            # 最常用：详细 + 隐藏 + 可读
ls -lt | head -5   # 最近改动的 5 个
```

现代替代 **eza**（更好看，需 `apt install eza`）：

```bash
eza --long --icons --git --tree --level=2
```

**坑**：`ls` 输出是给**人**看的；脚本里要遍历文件请用 `for f in *` 或 `find`，**不要**解析 `ls` 的输出（文件名带空格/换行会炸）。

### 1.4 `mkdir` — 建目录

```bash
mkdir project
mkdir -p a/b/c      # 递归建，父目录不存在也不报错
```

**坑**：不加 `-p` 时，父目录不存在会直接失败；脚本里几乎总该加 `-p`。

### 1.5 `rm` — 删（**最危险**）

```bash
rm file.txt
rm -r dir/          # 递归删目录
rm -rf dir/         # 强制、不确认 —— 慎重
rm -i *.log         # 逐个确认
```

**坑（致命的三个）**：
1. `rm -rf /` 或 `rm -rf ~` 没有回收站，**删了就是没了**；
2. 变量为空时 `rm -rf $DIR/` 会变成 `rm -rf /` —— 脚本里先判空：`[ -n "$DIR" ] || exit 1`；
3. 通配符先展开再执行，`rm *.log` 前先 `ls *.log` 看一眼。

> 安全习惯：`rm -rf` 前先 `echo rm -rf $TARGET` 打印出来核对，确认无误再真跑。

### 1.6 `cp` — 复制

```bash
cp a.txt b.txt              # 文件 → 文件
cp -r src/ dst/             # 目录 → 目录
cp -a src/ dst/             # 保留权限/时间戳/链接（备份首选，等价 -dR --preserve=all）
cp -v a.txt /tmp/           # 显示过程
```

**坑**：目标目录已存在时，`cp -r src dst` 会变成 `dst/src`；想"把 src 里的内容倒进 dst"用 `cp -r src/. dst/`。

### 1.7 `mv` — 移动 / 重命名

```bash
mv old.txt new.txt          # 同目录 = 重命名
mv file.txt dir/            # 移动到目录
mv dir1 dir2                # 若 dir2 存在 → dir1 变成 dir2/dir1
```

**坑**：跨文件系统移动 = 复制 + 删除，**大文件会顿一下且不是原子操作**；目标同名文件会被**静默覆盖**（想拦就 `mv -n`）。

### 1.8 `cat` / `head` / `tail` — 看内容

```bash
cat -n file.txt             # 带行号
cat a.txt b.txt > merged    # 拼接
head -n 20 file.txt         # 前 20 行
head -c 200 file.txt        # 前 200 字节
tail -n 50 file.txt         # 后 50 行
tail -f /var/log/syslog     # 持续跟踪（排障神器，Ctrl+C 退出）
```

**坑**：`cat` 一个几 GB 的文件会把终端刷死；大文件用 `less`（`q` 退出）或 `head/tail`。

### 1.9 `find` — 按条件找文件

```bash
find . -name "*.log"                        # 按名字
find . -type f -name "*.tmp"                # 只要普通文件
find /var/log -type f -mtime -7             # 7 天内改过
find . -size +10M                           # 大于 10MB
find . -name "*.log" -exec rm {} \;         # 找到就删（危险，先试 -print）
find . -name "*.log" -delete                # 同上，更简洁
```

**坑**：`-exec ... \;` 对每个文件执行一次；想批量传参用 `-exec ... +`（快得多）。
**更重要的坑**：先把 `-exec` 换成 `-print` 跑一遍，确认命中的是你要删的那批文件。

---

## 2. 文本过滤与管道（任务 b）

### 2.1 `grep` — 按行过滤

| 参数 | 作用 |
|---|---|
| `-i` | 忽略大小写 |
| `-n` | 显示行号 |
| `-r` | 递归搜目录 |
| `-v` | **反选**（不含该模式的行） |
| `-c` | 只输出匹配行数 |
| `-l` | 只输出含匹配的文件名 |
| `-E` | 扩展正则（等价 `egrep`） |

```bash
grep ERROR demo.log                 # 含 ERROR 的行
grep -in "error" demo.log           # 忽略大小写 + 行号
grep -c ERROR demo.log              # 计数
grep -rn "TODO" src/                # 递归搜源码
grep -v "^#" config.ini             # 去掉注释行
```

**坑**：`grep` 的退出码有含义——**0=有匹配，1=无匹配，2=出错**。脚本里 `if grep -q ...; then` 就是在用这个。

### 2.2 `wc` — 数数

```bash
wc -l file.txt      # 行数（最常用）
wc -w file.txt      # 词数
wc -c file.txt      # 字节数
grep -c ERROR demo.log   # 通常比 wc 更直接
```

**坑**：`wc -l` 数的是**换行符**；最后一行没有换行符时，结果会比"肉眼行数"少 1。

### 2.3 重定向与管道

| 写法 | 含义 |
|---|---|
| `cmd > file` | stdout 覆盖写入（**先清空**） |
| `cmd >> file` | stdout 追加 |
| `cmd 2> err.log` | stderr 单独存 |
| `cmd > out.log 2>&1` | stdout 和 stderr 合并进同一文件 |
| `cmd < input.txt` | 从文件读 stdin |
| `cmd > /dev/null` | 丢弃输出（静音） |
| `a \| b` | a 的 stdout 作为 b 的 stdin |

**组合示例：一次真实的日志统计**

```bash
grep ERROR demo.log | wc -l                       # ERROR 有几行
grep ERROR demo.log | sort | uniq -c | sort -rn   # 各条错误的出现次数排行
tail -n 1000 app.log | grep -v DEBUG > clean.log 2>&1
find . -name "*.log" -exec grep -l ERROR {} +     # 哪些日志里出现过 ERROR
```

**坑（三个高频）**：
1. **`>` 会先清空目标文件**：`sort file > file` 会得到一个空文件（因为重定向在命令执行前就截断了）。要就地处理用临时文件或 `sponge`。
2. **stderr 不会进管道**：`cmd | grep xxx` 看不到报错。要合并就 `cmd 2>&1 | grep xxx`。
3. **命令顺序有讲究**：`cmd > out 2>&1` 对；`cmd 2>&1 > out` 错（此时 stderr 还指向旧的终端）。

---

## 3. 系统状态与进程（任务 c）

### 3.1 `ps aux` — 进程快照

```bash
ps aux                 # 全系统所有进程
ps aux | grep nginx    # 找某进程（注意：会把自己也匹配进去）
ps aux | grep [n]ginx  # 小技巧：方括号让它匹配不到自己
ps -ef                 # 另一种风格（含 PPID 层级更方便）
```

字段速读：`USER PID %CPU %MEM VSZ RSS STAT START TIME COMMAND`
`STAT` 里 `S`=睡眠 `R`=运行 `Z`=僵尸 `+`=前台进程组。

**坑**：`ps aux | grep xxx` 总会多出一行 grep 自己 —— 用 `grep -v grep` 或 `grep [x]xx`。

### 3.2 `top` — 实时监控

```bash
top
```

交互键：`P` 按 CPU 排序 / `M` 按内存排序 / `1` 展开每个核 / `k` 杀进程 / `q` 退出。
更友好的替代：`btop`（需 `apt install btop`）。

**坑**：`top` 头部的 "load average" 是 1/5/15 分钟均值；**看 CPU 是否过载要除以核数**（4 核 load 4.0 ≈ 满载）。

### 3.3 `kill` — 发信号

```bash
kill 1234              # 默认 TERM(15)：请求优雅退出
kill -TERM 1234        # 同上
kill -HUP 1234         # 让守护进程重载配置（很多服务支持）
kill -9 1234           # KILL：强杀，无法被捕获
killall nginx          # 按名字杀全部
pkill -f "python worker" # 按命令行模式杀
```

**坑**：`-9` 是最后手段 —— 进程没机会释放锁/刷盘/关连接，可能留下脏数据或僵尸文件。顺序应是 `TERM` → 等 → 还活着再 `KILL`。

### 3.4 `df -h` / `free -m` — 磁盘与内存

```bash
df -h          # 各分区使用率
df -i          # inode 使用率（"磁盘没满却写不进去"多半是 inode 满）
free -m        # 内存（单位 MB）
```

**读 `free` 的关键**：不要看 `free` 列，看 **`available`** 列 —— Linux 会把空闲内存拿去做缓存（`buff/cache`），这是正常的，不代表内存被吃光。

```bash
free -m | awk 'NR==2{printf "内存使用率: %.1f%%\n", $3/$2*100}'
```

**配套常用**：`du -sh *`（当前目录下各项占多大）、`du -sh /var/log`（某目录总量）。

---

## 4. 文件权限（任务 d）

### 4.1 权限的三要素

```
-rwxr-xr--  1 alice dev  1024 Oct 17 10:00 deploy.sh
 │└┬┘└┬┘└┬┘
 │ │  │  └── other（其他人）：r--
 │ │  └───── group（同组）：r-x
 │ └──────── owner（属主）：rwx
 └────────── 类型：- 文件 / d 目录 / l 链接
```

三种权限位：`r`=4 读、`w`=2 写、`x`=1 执行。**目录的 `x` 表示"能进入"**，缺了 `x` 就 `cd` 不进去，哪怕有 `r`。

### 4.2 `chmod` — 改权限

```bash
chmod 755 deploy.sh        # rwxr-xr-x  脚本可执行的标准权限
chmod 644 config.json      # rw-r--r--  普通文件
chmod 600 id_rsa           # rw-------  私钥必须这样
chmod u+x run.sh           # 给属主加执行
chmod g-w,o-r notes.txt    # 同组去写、其他人去读
chmod -R 755 static/       # 递归
```

**坑（最重要）**：递归改目录时，**目录需要 `x` 才能进入**。`chmod -R 644 dir` 会让你进不去这个目录 —— 目录通常要 `755`，文件才是 `644`。要分开处理：

```bash
find static -type d -exec chmod 755 {} +
find static -type f -exec chmod 644 {} +
```

### 4.3 `chown` — 改属主

```bash
chown alice file.txt           # 改属主
chown alice:dev file.txt       # 同时改属组
chown -R www-data:www-data /var/www
```

**坑**：普通用户**不能**把文件送人（`chown` 给别人需要 root），只有 root 能改属主。日常用 `sudo chown`；只改组且自己是该组成员时可用 `chgrp`。

### 4.4 `umask` — 新文件的默认权限（一句话）

默认 `umask 022` → 新建文件 `644`、新建目录 `755`。规则是"从 666/777 里减掉 umask 的位"。

---

## 5. 一页速查（贴墙版）

| 目的 | 命令 |
|---|---|
| 我在哪 / 去哪 | `pwd` / `cd -` |
| 看目录 | `ls -lah`、`ls -lt \| head` |
| 建目录 | `mkdir -p a/b/c` |
| 删（慎） | `rm -r dir`、`rm -i *.log` |
| 复制 / 移动 | `cp -a src/ dst/` / `mv old new` |
| 看内容 | `cat -n`、`head -n20`、`tail -f` |
| 找文件 | `find . -name "*.log" -mtime -7` |
| 过滤 | `grep -rin pattern .`、`grep -v`、`grep -c` |
| 计数 | `wc -l` |
| 重定向 | `> out 2>&1`、`>> append`、`\|` |
| 进程 | `ps aux \| grep [x]`、`top`、`kill -TERM` |
| 容量 | `df -h`、`df -i`、`du -sh *`、`free -m` |
| 权限 | `chmod 644/755`、`chown user:group` |

---

## 6. 20 分钟练习清单（做完就算掌握 a–d）

在 `~/ailab/lab03` 里逐条执行，**每条都要求你能预测输出再运行**：

```bash
# a) 目录与文件
mkdir -p sandbox/{logs,data}
cd sandbox && pwd
printf 'INFO ok\nERROR disk\nERROR net\nWARN slow\n' > logs/app.log
cp logs/app.log logs/app.bak
mv logs/app.bak logs/app.log.old
head -n 2 logs/app.log && tail -n 1 logs/app.log
find . -name "*.log" -type f

# b) 过滤与管道
grep -c ERROR logs/app.log
grep ERROR logs/app.log | wc -l
grep -v INFO logs/app.log > logs/no_info.log
echo "追加一行" >> logs/no_info.log
find . -name "*.log" -exec grep -l ERROR {} +

# c) 系统状态
ps aux | head -5
ps aux | grep [s]sh
df -h | head -3
free -m | head -2

# d) 权限
printf '#!/bin/bash\necho hi\n' > hi.sh
chmod 644 hi.sh && ls -l hi.sh      # 此时 ./hi.sh 会 Permission denied
chmod 755 hi.sh && ./hi.sh          # 输出 hi
mkdir secret && chmod 700 secret && ls -ld secret
```

**验收标准**：能不看文档写出上面的命令，并说清每条为什么这么写。

---

## 7. 自检题（附要点）

1. `ls` 和 `find` 都能列文件，什么时候必须用 `find`？
   → 需要**按属性筛选**（时间/大小/类型/嵌套深度）或**对结果执行操作**（`-exec`）时。脚本里别解析 `ls`。
2. `cmd > out.log 2>&1` 和 `cmd 2>&1 > out.log` 有何区别？
   → 前者两者都进文件；后者 stderr 仍指向终端（因为 `2>&1` 在 `> out.log` 之前就把 stderr 绑到了当时的 stdout）。
3. `free -m` 里 `available` 和 `free` 差在哪？为什么"内存快满了"经常是误判？
   → `free` 不含可回收的缓存；`available` 才是应用真正能拿到的量。
4. `chmod -R 644 some_dir` 为什么会让人进不去这个目录？
   → 目录需要 `x` 位才能进入/遍历；`644` 去掉了 `x`。
5. `kill -9` 为什么是最后手段？
   → 进程无法捕获，没机会释放锁、刷盘、关连接，可能留下不一致状态。
6. 为什么 `rm -rf $DIR/` 在脚本里很危险？
   → 若 `$DIR` 为空，命令退化成 `rm -rf /`；必须先判空。

---

## 8. 附：Windows / PowerShell 对照（WSL 装好前先练概念）

| 任务 | Linux | PowerShell |
|---|---|---|
| 当前位置 | `pwd` | `Get-Location` / `pwd` |
| 列目录 | `ls -lah` | `Get-ChildItem` / `ls` |
| 建目录 | `mkdir -p a/b` | `New-Item -ItemType Directory -Force a\b` |
| 删除 | `rm -r dir` | `Remove-Item -Recurse dir` |
| 复制/移动 | `cp -a` / `mv` | `Copy-Item -Recurse` / `Move-Item` |
| 看内容 | `cat -n` / `head` / `tail -f` | `Get-Content` / `-TotalCount` / `-Tail -Wait` |
| 查找 | `find . -name "*.log"` | `Get-ChildItem -Recurse -Filter *.log` |
| 过滤 | `grep -rin x .` | `Select-String -Pattern x -Recurse` |
| 计数 | `wc -l` | `Measure-Object -Line` |
| 重定向 | `> out 2>&1` | `> out 2>&1`（`*>` 也可） |
| 进程 | `ps aux` / `top` | `Get-Process` / `Sort-Object CPU -Descending` |
| 杀进程 | `kill -TERM pid` | `Stop-Process -Id pid` |
| 磁盘 | `df -h` | `Get-PSDrive` / `Get-Volume` |
| 内存 | `free -m` | `Get-CimInstance Win32_OperatingSystem` |
| 权限 | `chmod 755` / `chown` | `icacls` / `takeown`（**模型完全不同：ACL 而非 9 位权限**） |

**关键差异**：Linux 路径大小写敏感（`File.txt` ≠ `file.txt`），Windows 不敏感；Linux 权限是 9 位位图，Windows 是 ACL 列表 —— 所以 `chmod` 那套在 PowerShell 里没有等价物。

---

## 9. 专题：过滤指定日志文本并输出新文件

> 对应 Task 03 交付动作之一。本节配方 **2026-10-17 在 Git Bash 5.3.15 / GNU grep 3.0 实测通过**，标注 ✅ 的为实测结果。

### 9.1 一条命令搞定

```bash
grep ERROR app.log > errors.log
```

✅ 实测：6 行日志 → **3 行**（含中文行 `ERROR 连接被拒绝` 也能匹配）。

### 9.2 三个需要先想清楚的问题

| 问题 | 决定项 | 常用取值 |
|---|---|---|
| 过滤**什么** | 模式与选项 | `-i` 忽略大小写、`-v` 反选、`-E` 正则、`-w` 整词 |
| 要不要**上下文** | `-A`/`-B`/`-C n` | 排障时 `-C 2`（前后各 2 行）几乎是标配 |
| 输出到**哪** | `>` / `>>` / `tee` | 新文件 `>`、累积 `>>`、边看边存 `tee` |

### 9.3 六种"指定文本"的写法

```bash
# 1) 单关键字
grep ERROR app.log > errors.log

# 2) 多关键字（正则）
grep -E 'ERROR|WARN' app.log > issues.log
```
✅ 实测：`-E 'ERROR|WARN'` → 4 行

```bash
# 3) 排除噪音（反选）
grep -vE 'INFO|DEBUG' app.log > meaningful.log
```
✅ 实测：`-v INFO` → 4 行

```bash
# 4) 带上下文（排障最重要的一招）
grep -n -C 2 ERROR app.log > error_context.log

# 5) 整词匹配（ERROR 不匹配 ERRORS）
grep -w ERROR app.log > strict.log

# 6) 模式写在文件里（模式多时）
printf 'ERROR\nWARN\n' > patterns.txt
grep -f patterns.txt app.log > issues.log
```

### 9.4 输出方式对比

| 写法 | 行为 | 场景 |
|---|---|---|
| `cmd > new.log` | 覆盖写，**先清空** | 生成新文件（本节主用法） |
| `cmd >> new.log` | 追加 | 多轮结果汇总 |
| `cmd \| tee new.log` | 屏幕 + 文件同时 | 想边看边存 |
| `cmd \| tee -a new.log` | 追加 + 屏幕 | 持续监控 |
| `cmd > out 2>&1` | stdout 与 stderr 一起收 | 连报错一起留证 |

✅ 实测：`grep -c ERROR app.log | tee counts.txt` 屏幕与文件都有值。

### 9.5 五个坑（第 1 个是实测撞出来的）

**坑 1：输出到同一个文件 → 文件被清空**

```bash
grep ERROR same.log > same.log      # ❌
```

✅ 实测：**执行前 6 行 → 执行后 0 行**。
原因：shell 在启动 `grep` **之前**就已把该文件以截断方式打开，grep 去读时已是空文件。GNU grep 会警告 `input file 'same.log' is also the output`，但**截断已经发生，警告救不回来**。

正确做法（✅ 实测 3 行）：

```bash
grep ERROR same.log > same.log.tmp && mv same.log.tmp same.log
```

**坑 2：`>` 与 `>>` 混用丢数据** —— 循环里忘记 `>>`，最后只剩最后一条。

**坑 3：stderr 不进管道也不进文件** —— 要 `2>&1`。

**坑 4：二进制文件只提示一句** —— 看到 `Binary file xxx matches` 就加 `-a`。

**坑 5：编码不一致导致"明明有却搜不到"** —— 日志是 GBK 而终端是 UTF-8 时中文搜不到：

```bash
file -i app.log                       # 先看真实编码
iconv -f GBK -t UTF-8 old.log > new.log
```

（✅ 实测补充：本机 `LANG` 未设置，但 UTF-8 中文匹配正常 —— **英文关键字不受编码影响，只有中文要留意**。）

### 9.6 结果怎么验

```bash
wc -l errors.log                                   # 行数对不对
head -5 errors.log                                 # 抽头几行看内容
diff <(grep ERROR app.log) errors.log && echo 一致   # 与直接过滤比对
```

### 9.7 grep 的退出码（脚本里判特重要）

```bash
grep -q ERROR app.log;  echo $?   # 0 = 有匹配  ✅实测
grep -q NOTHING app.log; echo $?  # 1 = 无匹配  ✅实测
# 2 = 出错（文件不存在/参数错误）
```

所以可以写 `if grep -q ERROR app.log; then echo 有错误; fi`。

### 9.8 PowerShell 对照（不装 bash 也能做）

```powershell
# 过滤并写入新文件（务必指定 UTF-8，PS 5.1 的 > 默认是 UTF-16）
Get-Content app.log | Select-String -Pattern 'ERROR' | ForEach-Object { $_.Line } |
  Set-Content errors.log -Encoding utf8

# 反选
Get-Content app.log | Where-Object { $_ -notmatch 'INFO' } | Set-Content no_info.log -Encoding utf8
```

---

## 10. 专题：批量重命名（实测配方）

> 对应 Task 03 交付动作之一。配方 **2026-10-17 在 Git Bash 5.3.15 实测通过**。

### 10.1 先记住一个坏消息

✅ 实测本机环境：`rename`、`mmv`、`qmv` **全都不存在**（Git Bash 不带）。
所以网上大量教程里的 `rename 's/xx/yy/' *.txt` 在这里会直接 `command not found` —— **`for` + 参数展开才是零依赖、通吃的正解**。

### 10.2 四种常用配方

```bash
# 1) 改扩展名
for f in *.txt; do mv -- "$f" "${f%.txt}.md"; done
```
✅ 实测：`f1.txt f2.txt f3.txt` → `f1.md f2.md f3.md`

```bash
# 2) 换前缀（必须两步展开）
for f in note_*.txt; do
  base="${f%.txt}"                   # note_1   ← 先去扩展名
  mv -- "$f" "${base/note_/doc_}.md" # doc_1.md ← 再换前缀
done
```
✅ 实测：`note_1.txt …` → `doc_1.md …`

```bash
# 3) 批量加序号（零填充，排序才不会 1,10,2）
i=1; for f in *.jpg; do mv -- "$f" "$(printf 'img_%03d.jpg' "$i")"; i=$((i+1)); done
```
✅ 实测：`apple.jpg banana.jpg cherry.jpg` → `img_001.jpg img_002.jpg img_003.jpg`

```bash
# 4) 大小写 / 空格清理
f="Report_Final.TXT"
echo "${f,,}"                                  # report_final.txt ← 全小写
for f in *.jpg; do mv -- "$f" "${f// /_}.bak"; done
```
✅ 实测：`my photo 1.jpg` → `my_photo_1.jpg.bak`

### 10.3 参数展开速查（批量重命名的核心）

| 写法 | 含义 | 例（`f=note_01.txt`） |
|---|---|---|
| `${f%.txt}` | 去掉**最短**后缀 | `note_01` |
| `${f%%.*}` | 去掉**最长**后缀 | `note_01` |
| `${f#note_}` | 去掉**最短**前缀 | `01.txt` |
| `${f##*_}` | 去掉**最长**前缀 | `01.txt` |
| `${f/note_/doc_}` | 替换**第一处** | `doc_01.txt` |
| `${f// /_}` | 替换**全部** | 空格全变下划线 |
| `${f,,}` / `${f^^}` | 全小写 / 全大写 | — |

记忆：`#` 砍左边、`%` 砍右边、`/` 替换；单写最短、双写最长。

### 10.4 踩过的坑（真实）

```bash
mv -- "$f" "doc_${f%.txt}.md"   # ❌ 得到 doc_note_1.md
```

`${f%.txt}` **只去掉扩展名**，`note_` 前缀还在。这就是"参数展开要一步步想：这一步之后字符串还剩什么"。

### 10.5 安全流程（比配方重要）

```bash
# 第 1 步：干跑，只打印不动手
for f in *.txt; do
  base="${f%.txt}"
  echo "mv -- \"$f\" \"${base/note_/doc_}.md\""
done

# 第 2 步：确认命中数量
for f in *.txt; do echo "$f"; done | wc -l

# 第 3 步：去掉 echo，真正执行
```

| 细节 | 为什么 |
|---|---|
| `mv -- "$f" …` 加 `--` 和引号 | 文件名含空格/以 `-` 开头时才不炸 |
| 用 `mv -n` | 默认 `mv` 会**静默覆盖**同名文件 |
| 先 `cd` 到目标目录并 `ls` | 通配符依赖当前目录，跑错目录=改错文件 |

### 10.6 如果要 `rename`（注意两个同名版本）

| 版本 | 语法 | 系统 |
|---|---|---|
| Perl 版 | `rename 's/旧/新/' *.txt` | Debian/Ubuntu |
| util-linux 版 | `rename 旧 新 *.txt` | CentOS/RHEL |

Ubuntu 上 `apt install rename` 装的是 Perl 版，支持 `-n` 干跑：

```bash
rename -n 's/\.txt$/.md/' *.txt   # 干跑
rename    's/\.txt$/.md/' *.txt   # 真改
```

### 10.7 PowerShell 对照

```powershell
# 改扩展名
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '\.txt$', '.md' }

# 干跑（-WhatIf 只报告不执行）
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '\.txt$','.md' } -WhatIf
```

---

## 参考

- Ubuntu 官方命令手册：<https://manpages.ubuntu.com/>
- `man` 是你的第一手资料：`man ls`、`man grep`、`man find`（`q` 退出，`/关键词` 搜索）
- <https://www.gnu.org/software/coreutils/manual/>
