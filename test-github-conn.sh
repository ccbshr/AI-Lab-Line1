#!/usr/bin/env bash
# 测试到 GitHub 的连通性：DNS / HTTPS(git) / SSH(22) / 代理
set -uo pipefail

echo "=== 1) DNS 解析 ==="
getent hosts github.com 2>/dev/null || nslookup github.com 2>&1 | tail -6

echo
echo "=== 2) HTTPS：用 git ls-remote 列出远程引用（最轻的连通性测试，不改本地）==="
timeout 25 git ls-remote https://github.com/git/git.git HEAD 2>&1
echo "git_exit=$?"

echo
echo "=== 3) SSH 22 端口可达性（无 key 时报 publickey 即为网络通）==="
timeout 20 ssh -T -o BatchMode=yes -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 git@github.com 2>&1
echo "ssh_exit=$?"

echo
echo "=== 4) 代理相关配置 ==="
git config --global --get http.proxy || echo "(未配置 http.proxy)"
env | grep -iE 'https?_proxy|all_proxy' || echo "(无 proxy 环境变量)"

echo
echo "=== 5) 已有 SSH key 吗 ==="
ls -1 "$HOME/.ssh" 2>/dev/null || echo "(~/.ssh 不存在)"
