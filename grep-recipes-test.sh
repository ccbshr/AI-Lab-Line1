#!/usr/bin/env bash
# 文本过滤 → 输出新文件：配方实测
set -uo pipefail
T=$(mktemp -d); cd "$T" || exit 1

echo "grep: $(grep --version | head -1)"
echo "locale: $(locale 2>/dev/null | head -1)"
echo

cat > app.log <<'EOF'
2026-10-17 10:00:01 INFO  startup ok
2026-10-17 10:00:07 ERROR disk full on /dev/sda1
2026-10-17 10:00:15 WARN  slow response 1200ms
2026-10-17 10:00:22 ERROR timeout calling db
2026-10-17 10:00:31 INFO  retry ok
2026-10-17 10:00:44 ERROR 连接被拒绝
EOF
echo "原始: $(wc -l < app.log) 行"

echo
echo "--- 1) 基本过滤 -> 新文件 ---"
grep ERROR app.log > errors.log
echo "errors.log: $(wc -l < errors.log) 行"; sed 's/^/    /' errors.log

echo
echo "--- 2) 只计数 -c ---"
echo "    grep -c ERROR = $(grep -c ERROR app.log)"

echo
echo "--- 3) 反选 -v（去掉 INFO 行）---"
grep -v INFO app.log > no_info.log
echo "    no_info.log: $(wc -l < no_info.log) 行"

echo
echo "--- 4) 多关键字 -E ---"
grep -E 'ERROR|WARN' app.log > issues.log
echo "    issues.log: $(wc -l < issues.log) 行"

echo
echo "--- 5) 只输出匹配片段 -o ---"
grep -o 'ERROR' app.log | sort | uniq -c | sed 's/^/    /'

echo
echo "--- 6) 带行号 -n ---"
grep -n ERROR app.log | head -2 | sed 's/^/    /'

echo
echo "--- 7) tee：同时看屏幕 + 写文件 ---"
grep -c ERROR app.log | tee counts.txt >/dev/null
echo "    counts.txt 内容: $(cat counts.txt)"

echo
echo "--- 8) 追加 ->> ---"
echo "汇总: $(wc -l < errors.log) 条" >> counts.txt
sed 's/^/    /' counts.txt

echo
echo "--- 9) 中文匹配 ---"
grep '连接' app.log | sed 's/^/    /'
echo "    中文匹配行数 = $(grep -c '连接' app.log)"

echo
echo "--- 10) 经典事故：输出重定向到同一文件 ---"
cp app.log same.log
before=$(wc -l < same.log)
grep ERROR same.log > same.log
echo "    执行前 $before 行 → 执行后 $(wc -l < same.log) 行  ← 文件被清空了"

echo
echo "--- 11) 正确做法：临时文件 ---"
cp app.log same2.log
grep ERROR same2.log > same2.log.tmp && mv same2.log.tmp same2.log
echo "    same2.log: $(wc -l < same2.log) 行"

echo
echo "--- 12) grep 退出码 ---"
grep -q ERROR app.log; echo "    有匹配 → $?"
grep -q NOTHING_XYZ app.log; echo "    无匹配 → $?"

echo
echo "--- 13) 递归 + 只搜某类文件 ---"
mkdir -p sub; echo 'ERROR in sub' > sub/b.log; echo 'ERROR in a.txt' > sub/a.txt
grep -rn --include='*.log' ERROR sub | sed 's/^/    /'

cd /; rm -rf "$T"
echo
echo "清理完成"
