#!/usr/bin/env bash
# Task 04 实操演示：init → add/commit → log → 分支/合并 → 冲突解决 → 远程配置
# 全程在 ~/ailab/task04 内进行，不触碰全局配置、不推送任何东西。
set -uo pipefail

T="$HOME/ailab/task04"
[ -n "$T" ] || { echo "路径为空，退出"; exit 1; }
rm -rf "$T"; mkdir -p "$T"; cd "$T" || exit 1

sec() { echo; echo "================ $* ================"; }

sec "环境"
git --version
echo "工作目录: $(pwd)"
echo "--- 全局身份配置（若为空说明还没配）---"
git config --global --list 2>/dev/null | grep -E 'user\.(name|email)' || echo "(未配置全局 user.name / user.email)"

sec "1) git init + 本地身份（只在本仓库生效）"
git init -b main
git config user.name  "AI-Lab Trainee"
git config user.email "trainee@example.com"
echo "本仓库身份: $(git config user.name) <$(git config user.email)>"

sec "2) 第一次提交：status → add → commit"
printf '# AI-Lab Task04 练习仓库\n\n用于演示 Git 工作流。\n' > README.md
printf '*.log\nnode_modules/\n' > .gitignore
echo '--- git status --short（README 未跟踪、.gitignore 未跟踪）---'
git status --short
git add README.md .gitignore
echo '--- git status --short（已暂存）---'
git status --short
git commit -m "chore: 初始化仓库，添加 README 与 .gitignore"
echo '--- git log --oneline ---'
git log --oneline

sec "3) 第二次提交 + 确认 .gitignore 生效"
printf 'ERROR 不应被跟踪\n' > debug.log
echo '--- status 是否忽略了 debug.log（应看不到它）---'
git status --short
printf 'line A\n' > notes.txt
git add notes.txt
git commit -m "feat(notes): 添加 notes.txt"
echo '--- git log --oneline --graph --all ---'
git log --oneline --graph --all

sec "4) 分支：git checkout -b + 快进合并"
git checkout -b feature/greeting
printf 'hello\n' >> notes.txt
git add notes.txt
git commit -m "feat(notes): 追加问候语"
echo '--- 分支现状 ---'
git branch -vv
git checkout main
echo '--- 合并前 main 的图 ---'
git log --oneline --graph --all
git merge feature/greeting
echo '--- 合并后（fast-forward，无 merge 节点）---'
git log --oneline --graph --all

sec "5) 冲突现场：两个分支改同一行"
git checkout -b feature/conflict
printf 'from feature\n' > conflict.txt
git add conflict.txt
git commit -m "feat: feature 侧的 conflict.txt"
git checkout main
printf 'from main\n' > conflict.txt
git add conflict.txt
git commit -m "feat: main 侧的 conflict.txt"
echo '--- 执行 git merge feature/conflict（预期冲突）---'
git merge feature/conflict
echo "merge 退出码: $?（非 0 表示有冲突）"
echo '--- git status --short（UU = both modified）---'
git status --short
echo '--- 冲突文件里的标记 ---'
cat conflict.txt

sec "6) 解决冲突：编辑 → add → commit"
printf 'from main\nfrom feature\n' > conflict.txt
git add conflict.txt
git commit -m "merge: 解决 conflict.txt 冲突，保留双方内容"
echo '--- 解决后的最终历史图 ---'
git log --oneline --graph --all
echo '--- 冲突文件最终内容 ---'
cat conflict.txt

sec "7) 远程仓库（只配置，不推送）"
# 注意：这里必须用引号，且不能写 <你的账号> —— shell 会把 < > 当成重定向
git remote add origin "https://github.com/USERNAME/REPO.git"
git remote -v || true

sec "8) 常用只读命令速览"
echo "--- git status ---"; git status | head -5
echo "--- git branch -a ---"; git branch -a
echo "--- git log --oneline --graph --all -10 ---"; git log --oneline --graph --all -10

echo
echo "==== 演示结束，仓库位置: $T ===="
