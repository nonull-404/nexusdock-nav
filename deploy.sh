#!/usr/bin/env bash
# 把本仓库的 config 同步到 O1 的 /opt/homepage/repo 并重启 homepage。
# 用法：
#   ./deploy.sh              # 在本机用 ssh 别名 o1 部署
#   REMOTE=local ./deploy.sh # 已经在 O1 上时直接本地部署
# 用前先 git commit（本脚本会 push 当前分支，保证线上版本在仓库里查得到）。
set -euo pipefail
cd "$(dirname "$0")"
REMOTE="${REMOTE:-o1}"

REMOTE_CMD='
set -e
sudo -n git -C /opt/homepage/repo fetch -q origin main
sudo -n git -C /opt/homepage/repo reset --hard -q origin/main
sudo -n docker restart homepage > /dev/null
sleep 5
# settings.yaml 改了标题/主题后必须重建静态页才生效（页面右下角的刷新按钮就是打这个接口）
curl -s -X POST http://127.0.0.1:3013/api/revalidate > /dev/null
echo "synced + restarted + revalidated"
'

git push -q origin HEAD
if [ "$REMOTE" = "local" ] || [ "$(hostname -s)" = "o1" ]; then
  sh -c "$REMOTE_CMD"
else
  ssh "$REMOTE" "$REMOTE_CMD"
fi
