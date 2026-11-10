#!/bin/bash
# WallpaperMachine Intel fork — 编译+打包 (Release)
# 用法: ./buildX86.sh
set -e
cd "$(dirname "$0")"

step() { echo -e "\n\033[1;34m=== $1 ===\033[0m"; }
warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }
fail() { echo -e "\033[1;31m✗ $1\033[0m"; exit 1; }

CONFIG=Release
PRODUCT_DIR=build/Build/Products/$CONFIG

step "清理旧产物"
if [ -d "$PRODUCT_DIR" ]; then
  echo "删除 $PRODUCT_DIR 下旧 dmg、app、appex..."
  rm -f "$PRODUCT_DIR"/*.dmg "$PRODUCT_DIR"/*.sha256
  rm -rf "$PRODUCT_DIR"/WallpaperMachine.app "$PRODUCT_DIR"/WallpaperMachineExtension.appex
fi

step "编译 (Release)"
LOG=/Users/lin/Doubao/chats/2026-11-06/new-chat/build-app.log
python3 scripts/build.py --configuration $CONFIG 2>&1 | tee "$LOG" || fail "编译失败，看 $LOG"

step "运行测试"
python3 scripts/test.py || warn "测试有失败，但继续打包"

step "打包 dmg"
python3 scripts/package.py --configuration $CONFIG --install || fail "打包失败"

DMG=$(find "$PRODUCT_DIR" -name "*.dmg" -newer "$LOG" 2>/dev/null | head -1)
if [ -z "$DMG" ]; then
  DMG=$(find build/Build/Products -name "*.dmg" 2>/dev/null | head -1)
fi

if [ -n "$DMG" ]; then
  cp "$DMG" /Users/lin/Downloads/
  echo -e "dmg 已拷贝到: \033[1;32m~/Downloads/$(basename "$DMG")\033[0m"
else
  echo "没找到 dmg 文件"
fi
