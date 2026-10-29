#!/usr/bin/env bash
# 演示：如何在任何位置确认"我在不在仓库里、仓库根在哪"
set -uo pipefail

probe() {
  local where="$1"
  echo "=============================="
  echo "当前目录: $where"
  echo "--- pwd ---"; pwd
  echo "--- 是否在仓库工作区内 ---"
  git rev-parse --is-inside-work-tree 2>&1 || echo "  (非仓库)"
  echo "--- 仓库根目录（最可靠的答案）---"
  git rev-parse --show-toplevel 2>&1 || echo "  (非仓库)"
  echo "--- .git 在哪 ---"
  git rev-parse --git-dir 2>&1 || echo "  (非仓库)"
}

# 1) 在真实仓库里
if [ -d "$HOME/ailab/task04/.git" ]; then
  cd "$HOME/ailab/task04"
  probe "仓库根目录本身"
  echo "--- 分支与上游 ---"; git status -sb | head -1
  echo "--- remote ---"; git remote -v
fi

echo
# 2) 在仓库的子目录里（pwd ≠ 仓库根）
if [ -d "$HOME/ailab/task04" ]; then
  cd "$HOME/ailab/task04" && mkdir -p deep/nested/dir && cd deep/nested/dir
  probe "仓库内的深层子目录"
  echo "  ↑ 注意：pwd 是子目录，但 --show-toplevel 依然给出仓库根"
  rmdir --ignore-fail-on-non-empty "$HOME/ailab/task04/deep/nested/dir" \
        "$HOME/ailab/task04/deep/nested" "$HOME/ailab/task04/deep" 2>/dev/null
fi

echo
# 3) 在家目录（不是仓库）
cd "$HOME"
probe "家目录（非仓库）"

echo
# 4) 在 /tmp（不是仓库）
cd /tmp
probe "/tmp（非仓库）"

echo
echo "=============================="
echo "在本机搜索所有仓库（找 .git）"
find "$HOME" -maxdepth 4 -name .git 2>/dev/null | head -10
echo "说明：.git 可能是目录，也可能是文件（worktree / submodule 场景）"
