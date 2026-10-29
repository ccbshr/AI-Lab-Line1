#!/usr/bin/env bash
# 收尾：排除个人作业文档 → 加 .gitattributes/README → 提交 → 推送 → 验证
set -uo pipefail

WS="/c/Users/29813/Documents/deepseek-harness/default-workspace"
cd "$WS" || exit 1

echo "=== 1) 从仓库排除个人作业文档（磁盘文件保留）==="
DOCX="生涯人物访谈提纲.docx"
if git ls-files --error-unmatch "$DOCX" >/dev/null 2>&1; then
  git rm --cached -q "$DOCX"
  echo "已从索引移除: $DOCX"
else
  echo "不在索引中: $DOCX"
fi
if ! grep -q '访谈提纲' .gitignore 2>/dev/null; then
  printf '\n# 个人作业文档（不属于本项目）\n*访谈提纲.docx\n' >> .gitignore
  echo "已写入 .gitignore"
fi

echo
echo "=== 2) 暂存新文件 ==="
git add -A
git status --short | head -10 | sed 's/^/  /'

echo
echo "=== 3) 提交 ==="
git commit -q -m "chore: 规范行尾与目录说明，排除个人作业文档"
git log --oneline -2 | sed 's/^/  /'

echo
echo "=== 4) 推送（上游已设置，直接 push）==="
timeout 180 git push 2>&1 | sed 's/^/  /'
echo "push 退出码: ${PIPESTATUS[0]:-?}"

echo
echo "=== 5) 验证：分支最新提交 & 文件数 ==="
echo "--- 远程分支 HEAD ---"
timeout 60 git ls-remote --heads origin zhangzechuan-ailab 2>&1 | sed 's/^/  /'
echo "--- 本地与远程是否同步 ---"
git status -sb | head -2 | sed 's/^/  /'
echo "--- 分支内文件数 ---"
echo "  $(git ls-tree -r --name-only HEAD | wc -l) 个文件"
echo "--- docx 是否已不在版本库 ---"
git ls-tree -r --name-only HEAD | grep -c '访谈提纲' | sed 's/^/  命中数: /'

echo
echo "=== 6) 与 main 的关系 ==="
echo "  main 提交数: $(git rev-list --count origin/main 2>/dev/null || echo '?')"
echo "  本分支提交数: $(git rev-list --count HEAD)"
echo "  （未合并 main，PR 只包含本分支内容）"
