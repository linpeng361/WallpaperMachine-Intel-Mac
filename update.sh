#!/bin/bash
# WallpaperMachine Intel fork — GitHub 更新一键脚本
# 用法: ./update.sh
set -e

cd "$(dirname "$0")"

echo "=== 1. 拉取上游 ==="
git fetch origin

echo "=== 2. Rebase ==="
GIT_EDITOR=true git rebase origin/main

echo "=== 3. Push 到你的 GitHub ==="
git push github intel-mac-support:intel --force

echo "=== 4. 编译 ==="
python3 scripts/build.py 2>&1 | tee /Users/lin/Doubao/chats/2026-11-06/new-chat/build-app.log

echo "=== 5. 打包 dmg ==="
python3 scripts/package.py

echo "=== 完成 ==="
git log --oneline -8
echo "dmg: build/Build/Products/Debug/"
