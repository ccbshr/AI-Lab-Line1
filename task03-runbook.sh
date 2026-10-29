#!/usr/bin/env bash
# Task 03 交付用的操作序列：目录树 → 批量重命名 → 日志过滤
# 用 Git Bash 或 WSL 均可执行：bash task03-runbook.sh
set -euo pipefail

WORK="$HOME/ailab/task03"
[ -n "$WORK" ] || { echo "WORK 为空，拒绝执行"; exit 1; }
rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"
echo "== 工作目录: $(pwd) =="

# ---------- 1) 创建指定目录树 ----------
echo
echo "== 1) 创建目录树 =="
mkdir -p project/src/utils project/src/core project/tests project/logs project/docs
touch project/src/main.py
touch project/src/utils/helper.py
touch project/src/core/engine.py
touch project/tests/test_main.py
find project -type d | sort
echo "-- 文件:"
find project -type f | sort

# ---------- 2) 批量重命名文件 ----------
echo
echo "== 2) 批量重命名（note_N.txt -> doc_N.md）=="
mkdir -p rename_demo
cd rename_demo
for i in 1 2 3 4 5; do printf '第 %s 份材料\n' "$i" > "note_${i}.txt"; done
echo "-- 重命名前:"
ls -1
for f in note_*.txt; do
  base="${f%.txt}"                  # note_1
  mv -- "$f" "${base/note_/doc_}.md" # doc_1.md  ← 用参数展开替换前缀
done
echo "-- 重命名后:"
ls -1
cd ..

# ---------- 3) 过滤日志文本并输出为新文件 ----------
echo
echo "== 3) 过滤日志 =="
mkdir -p logs
cat > logs/app.log <<'EOF'
2026-10-17 10:00:01 INFO  startup ok
2026-10-17 10:00:07 ERROR disk full on /dev/sda1
2026-10-17 10:00:15 WARN  slow response 1200ms
2026-10-17 10:00:22 ERROR timeout calling db
2026-10-17 10:00:31 INFO  retry ok
2026-10-17 10:00:44 ERROR connection refused
EOF
echo "-- 原始日志行数: $(wc -l < logs/app.log)"
grep ERROR logs/app.log > logs/errors.log
echo "-- ERROR 行数: $(wc -l < logs/errors.log)"
echo "-- errors.log 内容:"
cat logs/errors.log

# ---------- 汇总 ----------
echo
echo "== 最终结构 =="
find . -maxdepth 3 | sort
