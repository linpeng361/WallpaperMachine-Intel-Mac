#!/bin/bash
# WallpaperMachine Intel fork — GitHub 更新一键脚本
# 用法: ./update.sh
set -e
cd "$(dirname "$0")"

# 全局禁用 git 编辑器（避免 vim 弹出）
export GIT_EDITOR=true
export GIT_SEQUENCE_EDITOR=true

# ---------- 工具函数 ----------
step() { echo -e "\n\033[1;34m=== $1 ===\033[0m"; }
warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }
fail() { echo -e "\033[1;31m✗ $1\033[0m"; exit 1; }

# 退出时自动恢复 stash
cleanup() {
  if [ "$STASHED" = "1" ]; then
    echo ""
    warn "恢复 stash..."
    git stash pop || warn "stash 恢复失败，手动 git stash pop"
  fi
}
trap cleanup EXIT

# ---------- 1. 检查状态 ----------
step "1/4 检查 git 状态"
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "有未提交改动，先 stash"
  git stash
  STASHED=1
fi

# ---------- 2. 拉取上游 ----------
step "2/4 拉取上游"
for i in 1 2 3; do
  if git fetch origin --prune; then break; fi
  warn "fetch 失败，第 $i 次重试..."
  sleep 3
  [ $i -eq 3 ] && fail "无法连接上游，请检查网络/代理"
done

# ---------- 3. 检查有无新提交 ----------
step "3/4 检查更新"
LOCAL_BASE=$(git merge-base HEAD origin/main)
UPSTREAM_HEAD=$(git rev-parse origin/main)

if [ "$LOCAL_BASE" = "$UPSTREAM_HEAD" ]; then
  echo "已经是最新，无需更新"
  echo ""
  git log --oneline -3
  exit 0
fi

NEW_COUNT=$(git rev-list --count HEAD..origin/main)
echo "上游有 $NEW_COUNT 个新提交："
echo ""
git log --oneline HEAD..origin/main
echo ""
read -p "继续 rebase 并 push？[y/N] " confirm
[ "$confirm" = "y" ] || [ "$confirm" = "Y" ] || { echo "已取消"; exit 0; }

# ---------- 4. Rebase ----------
# 注意：rebase 时 ours=上游(目标)，theirs=我们 fork(被重放的commit)
if ! GIT_EDITOR=true git rebase origin/main; then
  warn "Rebase 有冲突，自动处理已知文件..."
  RESOLVED=0

  # xcstrings: 取上游版本（自动生成的翻译文件）
  if [ -f App/Resources/Localizable.xcstrings ] && \
     grep -q "<<<<<<" App/Resources/Localizable.xcstrings; then
    warn "Localizable.xcstrings 冲突 → 取上游版本"
    git checkout --ours App/Resources/Localizable.xcstrings
    git add App/Resources/Localizable.xcstrings
    RESOLVED=1
  fi

  # README: 取我们 fork 的版本（Intel 定制）
  for f in README.md README.zh-CN.md; do
    if [ -f "$f" ] && grep -q "<<<<<<" "$f"; then
      warn "$f 冲突 → 取 Intel fork 版本"
      git checkout --theirs "$f"
      git add "$f"
      RESOLVED=1
    fi
  done

  # 检查还有没有其他冲突文件
  if [ "$RESOLVED" = "1" ]; then
    REMAINING=$(git diff --name-only --diff-filter=U | wc -l | tr -d ' ')
    if [ "$REMAINING" -gt 0 ]; then
      fail "还有 $REMAINING 个文件冲突需手动解决: git status 查看后 git rebase --continue"
    fi
  fi

  if GIT_EDITOR=true git rebase --continue; then
    echo "冲突已自动解决"
  else
    fail "rebase --continue 失败，手动解决: git status"
  fi
fi

# ---------- 3.5 确保 README 是 Intel fork 版本 ----------
# rebase 可能静默覆盖 README（git 自动合并取上游），rebase 后强制校验
if ! head -1 README.md | grep -q "Intel Mac"; then
  warn "README.md 被上游覆盖，恢复 Intel fork 版本..."
  cat > README.md << 'EOF'
# WallpaperMachine — Intel Mac Build

A fork of [WallpaperMachine](https://github.com/MMFoundation/WallpaperMachine) that runs on Intel Macs.

## What this is

The original app only supports Apple silicon (M1 and later). This fork was adapted with AI assistance (**Doubao**) to run on Intel Macs.

## What was changed

- Compilation target: arm64 → x86_64
- Homebrew paths: `/opt/homebrew` → `/usr/local`
- Added a GPU toggle for dual-GPU Macs (Intel integrated / AMD discrete)
- SteamCMD now detects the host CPU architecture at runtime
- DMG filename automatically tags the build architecture

## Tested on

| | |
|---|---|
| Model | MacBookPro16,1 (16" 2019, A2141) |
| CPU | Intel Core i9-9980HK |
| GPU | AMD Radeon Pro 5500M 8GB + Intel UHD 630 |
| macOS | 26.7.2 (OCLP) |

## Download

Get the latest `WallpaperMachine-*.dmg` from [Releases](../../releases/latest).

## Install

1. Open the dmg and drag to Applications
2. Right-click → Open on first launch (not notarized)
3. Or run: `xattr -dr com.apple.quarantine /Applications/WallpaperMachine.app`

## Notes

- GPU toggle defaults to **off** (integrated GPU, lower power). Enable in Settings → Performance → Advanced → Experimental.
- Energy monitoring reports zeros on Intel Macs (no Energy Gauge hardware). Not a bug.

## Credits

- Original: [MMFoundation/WallpaperMachine](https://github.com/MMFoundation/WallpaperMachine)
- AI assistant: [Doubao](https://www.doubao.com)
EOF
fi

if ! head -1 README.zh-CN.md | grep -q "Intel Mac"; then
  warn "README.zh-CN.md 被上游覆盖，恢复 Intel fork 版本..."
  cat > README.zh-CN.md << 'EOF'
# WallpaperMachine — Intel Mac 版

这是 [WallpaperMachine](https://github.com/MMFoundation/WallpaperMachine) 的 fork，让它能在 Intel 芯片的 Mac 上运行。

## 这是什么？

原版只支持 Apple 芯片（M1 及更新机型）。这个版本用 AI 助手（**豆包**）改造，让 Intel Mac 也能用。

## 改了什么？

- 编译目标从 arm64 改成 x86_64
- Homebrew 路径从 `/opt/homebrew` 改成 `/usr/local`
- 加了双显卡切换开关（Intel 核显 / AMD 独显）
- SteamCMD 运行时自动检测 CPU 架构
- 打包时自动按架构命名 dmg

## 测试机型

| 项目 | 信息 |
|---|---|
| 机型 | MacBook Pro 16寸 2019（A2141） |
| 芯片 | Intel Core i9 |
| 显卡 | AMD Radeon Pro 5500M + Intel 核显 |
| 系统 | macOS 26.7.2（OCLP） |

## 下载

在 [Releases](../../releases/latest) 里下载 `WallpaperMachine-*.dmg`。

## 安装

1. 双击 dmg，拖到「应用程序」文件夹
2. 第一次打开右键 → 打开（没有苹果开发者签名）
3. 或终端运行：`xattr -dr com.apple.quarantine /Applications/WallpaperMachine.app`

## 说明

- GPU 开关默认关（核显省电），在 设置 → 性能 → 高级 → 实验性 里打开
- 能耗监测在 Intel 上显示 0，因为 Intel Mac 没有能耗传感器硬件，不是 bug

## 致谢

- 原版：[MMFoundation/WallpaperMachine](https://github.com/MMFoundation/WallpaperMachine)
- AI 助手：[豆包](https://www.doubao.com)
EOF
fi

# 如果 README 被改了，amend 到 rebase 后的 HEAD
if ! git diff --quiet README.md README.zh-CN.md; then
  git add README.md README.zh-CN.md
  GIT_EDITOR=true git commit --amend --no-edit
fi

# ---------- 5. Push ----------
step "4/4 推送到 GitHub"
for i in 1 2 3; do
  if git push github intel-mac-support:intel --force; then break; fi
  warn "push 失败，第 $i 次重试..."
  sleep 3
  [ $i -eq 3 ] && fail "无法 push，检查 PAT 权限或网络"
done

# ---------- 完成 ----------
step "完成"
git log --oneline -8
echo ""
echo "编译打包: ./buildX86.sh"
