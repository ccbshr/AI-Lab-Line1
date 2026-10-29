#!/usr/bin/env bash
# 方案 A：清理临时文件 → 整理提交 → 推送新分支 zhangzechuan-ailab → 验证
set -uo pipefail

WS="/c/Users/29813/Documents/deepseek-harness/default-workspace"
cd "$WS" || exit 1

echo "=== 1) 移除误提交的临时文件 ==="
if git ls-files --error-unmatch .tmp-probe.py >/dev/null 2>&1; then
  git rm --cached -q .tmp-probe.py
  echo "已从索引移除 .tmp-probe.py（文件仍在磁盘上）"
else
  echo ".tmp-probe.py 不在索引中"
fi

echo
echo "=== 2) 补进 .gitignore ==="
if ! grep -q '^\.tmp-probe\.py$' .gitignore; then
  printf '.tmp-probe.py\n' >> .gitignore
  echo "已追加 .tmp-probe.py"
else
  echo "已存在"
fi
git add .gitignore

echo
echo "=== 3) 整理首次提交（amend，尚未推送过，安全）==="
git commit --amend -q -m "chore: 初始化 AI-Lab 通识任务工作区（Task01-04 交付物、笔记库与脚本）"
git log --oneline
echo "本次提交文件数: $(git show --stat --oneline HEAD | tail -1)"

echo
echo "=== 4) 推送到新分支 zhangzechuan-ailab（不动 main） ==="
timeout 180 git push -u origin HEAD:zhangzechuan-ailab 2>&1 | sed 's/^/  /'
echo "push 退出码: ${PIPESTATUS[0]:-?}"

echo
echo "=== 5) 验证 ==="
echo "--- 本地分支与上游 ---"
git branch -vv | sed 's/^/  /'
echo "--- 远程是否存在该分支 ---"
timeout 60 git ls-remote --heads origin 2>&1 | sed 's/^/  /'

echo
echo "=== 6) 与远程 main 的关系（供发起 PR 参考）==="
git log --oneline origin/main -3 2>&1 | sed 's/^/  main: /'
echo "  （本地分支与 main 无共同祖先，PR 会显示为全新历史）"
