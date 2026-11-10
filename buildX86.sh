#!/bin/bash
# WallpaperMachine Intel fork — 单独编译+打包
# 用法: ./build.sh
set -e
cd "$(dirname "$0")"

step() { echo -e "\n\033[1;34m=== $1 ===\033[0m"; }
fail() { echo -e "\033[1;31m✗ $1\033[0m"; exit 1; }

step "清理旧产物"
DEBUG_DIR=build/Build/Products/Debug
if [ -d "$DEBUG_DIR" ]; then
  echo "删除旧 dmg、app、appex..."
  rm -f "$DEBUG_DIR"/*.dmg "$DEBUG_DIR"/*.sha256
  rm -rf "$DEBUG_DIR"/WallpaperMachine.app "$DEBUG_DIR"/WallpaperMachineExtension.appex
fi

step "编译"
LOG=/Users/lin/Doubao/chats/2026-11-06/new-chat/build-app.log
python3 scripts/build.py 2>&1 | tee "$LOG" || fail "编译失败，看 $LOG"

step "打包 dmg"
python3 scripts/package.py || fail "打包失败"

DMG=$(find build/Build/Products -name "*.dmg" -newer "$LOG" 2>/dev/null | head -1)
if [ -z "$DMG" ]; then
  DMG=$(find build/Build/Products -name "*.dmg" 2>/dev/null | head -1)
fi

if [ -n "$DMG" ]; then
  cp "$DMG" /Users/lin/Downloads/
  echo -e "dmg 已拷贝到: \033[1;32m~/Downloads/$(basename "$DMG")\033[0m"
else
  echo "没找到 dmg 文件"
fi
