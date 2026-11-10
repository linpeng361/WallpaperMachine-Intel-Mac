#!/bin/bash
# WallpaperMachine Intel fork — GitHub 更新一键脚本
# 用法: ./update.sh
set -e
cd "$(dirname "$0")"

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
