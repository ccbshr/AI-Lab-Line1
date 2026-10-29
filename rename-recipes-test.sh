#!/usr/bin/env bash
# 批量重命名配方实测：验证每种写法在当前 bash 里是否成立
set -uo pipefail
T=$(mktemp -d)
cd "$T" || exit 1
echo "tmp=$T"

mk() { rm -rf "$1"; mkdir -p "$1"; cd "$1" || exit 1; }

echo
echo "--- A) 改扩展名 .txt -> .md ---"
mk a; for i in 1 2 3; do echo x > "f$i.txt"; done
echo -n "前: "; ls -1 | tr '\n' ' '; echo
for f in *.txt; do mv -- "$f" "${f%.txt}.md"; done
echo -n "后: "; ls -1 | tr '\n' ' '; echo

echo
echo "--- B) 换前缀 note_ -> doc_（要用两步展开）---"
mk b; for i in 1 2 3; do echo x > "note_$i.txt"; done
echo -n "前: "; ls -1 | tr '\n' ' '; echo
for f in note_*.txt; do base="${f%.txt}"; mv -- "$f" "${base/note_/doc_}.md"; done
echo -n "后: "; ls -1 | tr '\n' ' '; echo

echo
echo "--- C) 批量加序号（printf 零填充）---"
mk c; for n in apple banana cherry; do echo x > "$n.jpg"; done
echo -n "前: "; ls -1 | tr '\n' ' '; echo
i=1; for f in *.jpg; do mv -- "$f" "$(printf 'img_%03d.jpg' "$i")"; i=$((i+1)); done
echo -n "后: "; ls -1 | tr '\n' ' '; echo

echo
echo "--- D) 大小写转换 ---"
mk d; echo x > "Report_Final.TXT"
f="Report_Final.TXT"
echo "lower=${f,,}   upper=${f^^}"
mv -- "$f" "${f,,}"
echo -n "后: "; ls -1 | tr '\n' ' '; echo

echo
echo "--- E) 文件名带空格（空格换下划线）---"
mk e; echo x > "my photo 1.jpg"
for f in *.jpg; do mv -- "$f" "${f// /_}.bak"; done
echo -n "后: "; ls -1 | tr '\n' ' '; echo

echo
echo "--- F) 外部工具可用性 ---"
for c in rename mmv qmv; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "$c: 存在 -> $(command -v "$c")"
  else
    echo "$c: 不存在"
  fi
done

echo
echo "--- G) rename 语法版本探测 ---"
if command -v rename >/dev/null 2>&1; then
  mk g; echo x > a1.txt
  if rename 's/a1/b1/' a1.txt 2>/dev/null; then
    echo "→ Perl 版语法（rename 's/旧/新/' 文件）可用"
  elif rename a1.txt b1.txt 2>/dev/null; then
    echo "→ util-linux 版语法（rename 旧 新 文件）可用"
  else
    echo "→ 两种语法都不可用，请改用 for 循环"
  fi
  ls -1 | tr '\n' ' '; echo
else
  echo "当前环境没有 rename 命令"
fi

cd /
rm -rf "$T"
echo
echo "清理完成"
