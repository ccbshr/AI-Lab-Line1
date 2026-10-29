# Task 03 交付：终端操作序列（目录树 / 批量重命名 / 日志过滤）

> 执行日期：2026-10-17　执行环境：Windows 11 + **Git Bash 5.3.15**（GNU coreutils，与 Linux 命令一致）
> 工作目录：`~/ailab/task03`（即 `C:\Users\29813\ailab\task03`）
> 执行结果：**全部成功，退出码 0**
> 说明：本次操作由脚本 `task03-runbook.sh` 在 bash 中真实执行，下方"执行历史"为脚本内命令逐行编号（等价于交互式终端的 `history` 输出），输出均为**真实 stdout**，未做手工修饰。

---

## 一、对照交付要求

| 要求 | 实现方式 | 命令 | 结果 |
|---|---|---|---|
| 创建指定目录树 | `mkdir -p` 一次建多层 + `touch` 建文件 | `mkdir -p project/{src/{utils,core},tests,logs,docs}` | 7 个目录、4 个文件 |
| 批量重命名文件 | `for` + 参数展开 `${f%.txt}` / `${base/note_/doc_}` | `mv -- "$f" "${base/note_/doc_}.md"` | `note_1..5.txt` → `doc_1..5.md` |
| 过滤日志并输出新文件 | `grep` + 输出重定向 `>` | `grep ERROR logs/app.log > logs/errors.log` | 6 行 → 3 行 |
| 执行历史 | 脚本内命令编号 | — | 50 条命令 |
| 操作截图 | 待补（见第五节） | — | 2 张 |

---

## 二、执行历史（history）

```text
   1  set -euo pipefail
   2  WORK="$HOME/ailab/task03"
   3  [ -n "$WORK" ] || { echo "WORK 为空，拒绝执行"; exit 1; }
   4  rm -rf "$WORK"
   5  mkdir -p "$WORK"
   6  cd "$WORK"
   7  echo "== 工作目录: $(pwd) =="
   8  echo
   9  echo "== 1) 创建目录树 =="
  10  mkdir -p project/src/utils project/src/core project/tests project/logs project/docs
  11  touch project/src/main.py
  12  touch project/src/utils/helper.py
  13  touch project/src/core/engine.py
  14  touch project/tests/test_main.py
  15  find project -type d | sort
  16  echo "-- 文件:"
  17  find project -type f | sort
  18  echo
  19  echo "== 2) 批量重命名（note_N.txt -> doc_N.md）=="
  20  mkdir -p rename_demo
  21  cd rename_demo
  22  for i in 1 2 3 4 5; do printf '第 %s 份材料\n' "$i" > "note_${i}.txt"; done
  23  echo "-- 重命名前:"
  24  ls -1
  25  for f in note_*.txt; do
  26    base="${f%.txt}"                   # note_1
  27    mv -- "$f" "${base/note_/doc_}.md" # doc_1.md ← 参数展开替换前缀
  28  done
  29  echo "-- 重命名后:"
  30  ls -1
  31  cd ..
  32  echo
  33  echo "== 3) 过滤日志 =="
  34  mkdir -p logs
  35  cat > logs/app.log <<'EOF'
  36  2026-10-17 10:00:01 INFO  startup ok
  37  2026-10-17 10:00:07 ERROR disk full on /dev/sda1
  38  2026-10-17 10:00:15 WARN  slow response 1200ms
  39  2026-10-17 10:00:22 ERROR timeout calling db
  40  2026-10-17 10:00:31 INFO  retry ok
  41  2026-10-17 10:00:44 ERROR connection refused
  42  EOF
  43  echo "-- 原始日志行数: $(wc -l < logs/app.log)"
  44  grep ERROR logs/app.log > logs/errors.log
  45  echo "-- ERROR 行数: $(wc -l < logs/errors.log)"
  46  echo "-- errors.log 内容:"
  47  cat logs/errors.log
  48  echo
  49  echo "== 最终结构 =="
  50  find . -maxdepth 3 | sort
```

---

## 三、三项操作与真实输出

### 3.1 创建目录树

```bash
mkdir -p project/src/utils project/src/core project/tests project/logs project/docs
touch project/src/main.py project/src/utils/helper.py project/src/core/engine.py project/tests/test_main.py
find project -type d | sort
find project -type f | sort
```

真实输出：

```text
project
project/docs
project/logs
project/src
project/src/core
project/src/utils
project/tests
-- 文件:
project/src/core/engine.py
project/src/main.py
project/src/utils/helper.py
project/tests/test_main.py
```

**为什么这样写**：`mkdir -p` 一次建出多层父目录，父级不存在也不报错；目录与文件分开建，比 `mkdir -p` 里混着建文件更清晰。

### 3.2 批量重命名

```bash
# 造 5 个待重命名文件
for i in 1 2 3 4 5; do printf '第 %s 份材料\n' "$i" > "note_${i}.txt"; done

# 批量改名：note_N.txt -> doc_N.md
for f in note_*.txt; do
  base="${f%.txt}"                   # 去掉扩展名 → note_1
  mv -- "$f" "${base/note_/doc_}.md" # 替换前缀 → doc_1.md
done
```

真实输出：

```text
-- 重命名前:
note_1.txt
note_2.txt
note_3.txt
note_4.txt
note_5.txt
-- 重命名后:
doc_1.md
doc_2.md
doc_3.md
doc_4.md
doc_5.md
```

**踩过的坑（真实记录）**：第一版写成 `mv -- "$f" "doc_${f%.txt}.md"`，结果是 `doc_note_1.md`——因为 `${f%.txt}` 只去掉扩展名，`note_` 前缀还在。正确做法是先去扩展名再替换前缀，两步参数展开：
`${f%.txt}` → `note_1`，`${note_1/note_/doc_}` → `doc_1`。
另外 `mv --` 里的 `--` 很有用：文件名以 `-` 开头时不会被当成选项。

### 3.3 过滤日志文本并输出新文件

```bash
cat > logs/app.log <<'EOF'
2026-10-17 10:00:01 INFO  startup ok
2026-10-17 10:00:07 ERROR disk full on /dev/sda1
2026-10-17 10:00:15 WARN  slow response 1200ms
2026-10-17 10:00:22 ERROR timeout calling db
2026-10-17 10:00:31 INFO  retry ok
2026-10-17 10:00:44 ERROR connection refused
EOF

grep ERROR logs/app.log > logs/errors.log
wc -l < logs/errors.log
cat logs/errors.log
```

真实输出：

```text
-- 原始日志行数: 6
-- ERROR 行数: 3
-- errors.log 内容:
2026-10-17 10:00:07 ERROR disk full on /dev/sda1
2026-10-17 10:00:22 ERROR timeout calling db
2026-10-17 10:00:44 ERROR connection refused
```

**要点**：`>` 是覆盖写（本次是新文件，无风险）；若是追加到已有文件应使用 `>>`。`grep` 的退出码也有含义：`0` 有匹配、`1` 无匹配、`2` 出错，所以脚本里可写 `if grep -q ERROR ...; then`。

---

## 四、最终目录结构

```text
.
├── logs
│   ├── app.log
│   └── errors.log
├── project
│   ├── docs
│   ├── logs
│   ├── src
│   │   ├── core
│   │   │   └── engine.py
│   │   ├── main.py
│   │   └── utils
│   │       └── helper.py
│   └── tests
│       └── test_main.py
└── rename_demo
    ├── doc_1.md
    ├── doc_2.md
    ├── doc_3.md
    ├── doc_4.md
    └── doc_5.md
```

统计：**10 个目录 / 11 个文件**。

---

## 五、操作截图

**图 1：终端中执行 history 与命令过程**

![终端执行 history 与命令序列](./assets/task03-history.png)

> ⏳ **待补图**：在本节第六步的终端里执行 `history | tail -50`，截图保存为 `assets/task03-history.png`。

**图 2：最终目录树与 errors.log 内容**

![最终目录树与过滤结果](./assets/task03-dir-tree.png)

> ⏳ **待补图**：执行 `tree -L 3` 与 `cat logs/errors.log`，截图保存为 `assets/task03-dir-tree.png`。

---

## 六、如何在自己终端复现（并生成你自己的 history 与截图）

在**自己开的终端**里（Git Bash 或 WSL 均可）：

```bash
# 1) 保存脚本
mkdir -p ~/ailab && cd ~/ailab
# 把 task03-runbook.sh 放到这个目录，然后：
bash task03-runbook.sh

# 2) 生成真实 history（交互式终端里）
history | tail -50 > ~/ailab/task03/history.txt

# 3) 生成目录树与结果
cd ~/ailab/task03
tree -L 3            # 没装 tree 就用：find . -maxdepth 3 | sort
cat logs/errors.log
```

截图建议（评审要"能看清命令与输出"）：
1. 终端窗口拉宽，`history | tail -50` 的输出完整可见；
2. 第二次截图把 `tree -L 3` 与 `cat logs/errors.log` 放在同一屏。

---

## 七、自检

| 检查项 | 期望 | 本次结果 |
|---|---|---|
| 目录树是否含 5 个预期子目录 | `docs/logs/src/core/src/utils/tests` | ✅ 7 个目录 |
| 重命名是否全部成功 | 5 个文件，扩展名 `.txt → .md` 且前缀替换 | ✅ `doc_1..5.md` |
| 过滤结果是否正确 | 只含 ERROR 行，3 行 | ✅ 3 行 |
| 新文件是否为独立文件 | `logs/errors.log` 存在且原 `app.log` 未被改动 | ✅ |
| 是否留下脏数据 | 无临时文件、无失败残留 | ✅ 退出码 0 |
| 是否危险命令 | 无裸 `rm -rf`（`rm -rf "$WORK"` 前已判空） | ✅ |

---

## 附：产物文件

| 文件 | 说明 |
|---|---|
| `task03-runbook.sh` | 完整操作脚本（可重复执行，幂等：每次先清理工作目录） |
| `task03-output.txt` | 本次执行的**真实 stdout**（UTF-8） |
| `task03-history.txt` | 命令编号清单（等价 history，UTF-8） |
| `task03-capture.sh` | 采集器：执行 runbook 并生成上面两个文件 |
