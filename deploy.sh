#!/usr/bin/env bash
# 把本仓库的 config 同步到 O1 的 /opt/homepage/repo 并重启 homepage。
# 用前先 git commit（本脚本会 push 当前分支，保证线上版本在仓库里查得到）。
set -euo pipefail
cd "$(dirname "$0")"
REMOTE="${REMOTE:-o1}"

git push -q origin HEAD
ssh "$REMOTE" 'set -e
  sudo -n git -C /opt/homepage/repo fetch -q origin main
  sudo -n git -C /opt/homepage/repo reset --hard -q origin/main
  sudo -n docker restart homepage > /dev/null
  sleep 5
  # settings.yaml 改标题/主题后必须重建静态页才生效
  curl -s -X POST http://127.0.0.1:3013/api/revalidate > /dev/null
  echo "synced + restarted + revalidated"'
