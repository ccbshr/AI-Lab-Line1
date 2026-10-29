#!/usr/bin/env bash
# 侦察：GitHub 账号、公开仓库列表、本地各仓库状态
set -uo pipefail
PY="/c/Users/29813/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/python.exe"

echo "=== 1) GitHub 账号确认（SSH）==="
timeout 20 ssh -T -o BatchMode=yes -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null git@github.com 2>&1
echo

echo "=== 2) 该账号的公开仓库（GitHub API，匿名可读）==="
JSON=/tmp/gh_repos.json
curl -s --max-time 30 "https://api.github.com/users/ccbshr/repos?per_page=100&sort=updated" -o "$JSON"
echo "HTTP 响应大小: $(wc -c < "$JSON") 字节"
"$PY" - "$JSON" <<'PYEOF'
import json, sys
try:
    data = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception as e:
    print("  解析失败:", e); sys.exit()
if isinstance(data, dict):
    print("  API 返回:", data.get("message", data))
    sys.exit()
if not data:
    print("  （没有公开仓库）")
    sys.exit()
print(f"  共 {len(data)} 个公开仓库：")
for r in data:
    print(f"   - {r['full_name']:<40} 大小 {r['size']:>7} KB  更新 {r['pushed_at']}")
PYEOF
echo

echo "=== 3) 本地已有仓库状态 ==="
for d in "$HOME/Desktop/code" "$HOME/ailab/task04" "/c/Users/29813/Documents/deepseek-harness/default-workspace"; do
  if [ -e "$d/.git" ]; then
    echo "--- $d ---"
    ( cd "$d" && echo "  分支: $(git branch --show-current || echo '(detached)')"
      echo "  remote:"; git remote -v | sed 's/^/    /' || true
      echo "  最近提交:"; git log --oneline -3 2>/dev/null | sed 's/^/    /' || echo "    (无提交)"
      echo "  未提交改动: $(git status --porcelain | wc -l) 个文件" )
  else
    echo "--- $d ---"
    echo "  (不是 git 仓库)"
  fi
done
echo

echo "=== 4) 辅助工具 ==="
command -v gh >/dev/null 2>&1 && echo "gh: $(gh --version | head -1)" || echo "gh: 未安装"
echo "git: $(git --version)"
echo "身份: $(git config --global user.name) <$(git config --global user.email)>"
