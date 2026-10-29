#!/usr/bin/env bash
# 侦察远程仓库内容 + 本地候选目录，判断该链接哪一个
set -uo pipefail
PY="/c/Users/29813/.dsh/dsh-runtimes/dsh-primary-runtime/dependencies/python/python.exe"
REPO="ccbshr/AI-Lab-Line1"

echo "=== 1) 远程仓库元信息 ==="
curl -s --max-time 30 "https://api.github.com/repos/$REPO" -o /tmp/gh_repo.json
"$PY" - <<'PYEOF'
import json
d = json.load(open("/tmp/gh_repo.json", encoding="utf-8"))
for k in ("full_name", "default_branch", "size", "created_at", "pushed_at", "private", "description"):
    print(f"  {k:<15}: {d.get(k)}")
PYEOF
echo

echo "=== 2) 远程分支（git ls-remote，无需克隆）==="
timeout 30 git ls-remote --heads "git@github.com:$REPO.git" 2>&1 | sed 's/^/  /'
echo

echo "=== 3) 远程仓库文件树（前 40 项）==="
BRANCH=$("$PY" -c "import json;print(json.load(open('/tmp/gh_repo.json'))['default_branch'])" 2>/dev/null || echo main)
curl -s --max-time 30 "https://api.github.com/repos/$REPO/git/trees/$BRANCH?recursive=1" -o /tmp/gh_tree.json
"$PY" - "$BRANCH" <<'PYEOF'
import json, sys
d = json.load(open("/tmp/gh_tree.json", encoding="utf-8"))
items = d.get("tree", [])
if not items:
    print("  （空仓库或获取失败）", d.get("message", ""))
else:
    print(f"  共 {len(items)} 项，前 40 项：")
    for it in items[:40]:
        print(f"   {it['type'][:4]:<5} {it['path']}")
PYEOF
echo

echo "=== 4) 本地候选：Desktop/code ==="
if [ -d "$HOME/Desktop/code" ]; then
  ls -1A "$HOME/Desktop/code" | head -20 | sed 's/^/  /'
  echo "  文件数: $(find "$HOME/Desktop/code" -type f -not -path '*/.git/*' | wc -l)"
else
  echo "  （不存在）"
fi
echo

echo "=== 5) 本地候选：default-workspace（顶层）==="
WS="/c/Users/29813/Documents/deepseek-harness/default-workspace"
ls -1A "$WS" | head -25 | sed 's/^/  /'
echo "  文件数: $(find "$WS" -type f -not -path '*/.git/*' | wc -l)"
