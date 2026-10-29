#!/usr/bin/env bash
# 把 default-workspace 链接到 ccbshr/AI-Lab-Line1：初始化 + .gitignore + 首次提交 + remote + fetch
# 注意：本脚本【不推送】，只完成本地准备与远程信息拉取
set -uo pipefail

WS="/c/Users/29813/Documents/deepseek-harness/default-workspace"
cd "$WS" || exit 1
echo "工作目录: $(pwd)"

echo
echo "=== 1) 写 .gitignore（排除渲染产物与临时文件）==="
cat > .gitignore <<'EOF'
# 渲染/校验产物
preview-*/
checks*.json

# 临时目录与临时脚本
.tmp-*/
*.tmp

# Python
__pycache__/
*.pyc

# 系统与编辑器噪音
.DS_Store
Thumbs.db
debug.log
EOF
echo "已写入 .gitignore"

echo
echo "=== 2) 初始化仓库 ==="
if [ -e .git ]; then
  echo "已存在 .git，跳过 init"
else
  git init -b main
fi

echo
echo "=== 3) 暂存并检查清单 ==="
git add -A
echo "--- 将提交的文件数: $(git diff --cached --name-only | wc -l) ---"
git diff --cached --name-only | head -30 | sed 's/^/  /'
echo "--- 被忽略的（前 10 项）---"
git status --porcelain --ignored 2>/dev/null | grep '^!!' | head -10 | sed 's/^/  /'

echo
echo "=== 4) 首次提交 ==="
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "已有提交历史，跳过"
else
  git commit -m "chore: 初始化 AI-Lab 通识任务工作区（Task01-04 交付物、笔记库与脚本）" | tail -3
fi

echo
echo "=== 5) 关联远程 ==="
if git remote get-url origin >/dev/null 2>&1; then
  echo "origin 已存在: $(git remote get-url origin)"
  git remote set-url origin git@github.com:ccbshr/AI-Lab-Line1.git
  echo "已更新为: $(git remote get-url origin)"
else
  git remote add origin git@github.com:ccbshr/AI-Lab-Line1.git
  echo "已添加: $(git remote get-url origin)"
fi

echo
echo "=== 6) 拉取远程信息（不改工作区）==="
timeout 60 git fetch origin 2>&1 | sed 's/^/  /'
echo "--- 远程分支 ---"
git branch -r | sed 's/^/  /'
echo "--- origin/main 最近 5 条提交 ---"
git log --oneline origin/main -5 2>&1 | sed 's/^/  /'
echo "--- origin/basic/zhangzechuan 最近 3 条 ---"
git log --oneline "origin/basic/zhangzechuan" -3 2>&1 | sed 's/^/  /'

echo
echo "=== 7) 当前态 ==="
git status -sb | head -3
echo "本地提交数: $(git rev-list --count HEAD 2>/dev/null || echo 0)"
echo "远程 main 提交数: $(git rev-list --count origin/main 2>/dev/null || echo 0)"
echo
echo "⚠️ 未执行任何 push —— 推送目标分支需先确认"
