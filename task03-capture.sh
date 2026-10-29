#!/usr/bin/env bash
# 采集器：执行 runbook 并生成 UTF-8 的 output / history 产物。
# 关键点：重定向由 bash 自己做，避免 PowerShell 5.1 把输出写成 UTF-16。
set -uo pipefail
cd "$(dirname "$0")"

bash ./task03-runbook.sh > task03-output.txt 2>&1
status=$?

grep -vE '^[[:space:]]*(#|$)' task03-runbook.sh | nl -ba -w4 -s'  ' > task03-history.txt

# 丢弃旧的 -x 轨迹（rename 前缀 bug 版本的，已过时）
rm -f task03-transcript.txt

echo "runbook 退出码: $status"
echo "output : $(wc -c < task03-output.txt) 字节"
echo "history: $(wc -l < task03-history.txt) 行"
