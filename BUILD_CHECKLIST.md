# 下次编译清单

在你自己的终端跑（agent 沙箱里 cargo/xcodebuild 会崩）：

```bash
cd /Users/lin/Doubao/chats/2026-11-06/new-chat/WallpaperMachine
python3 scripts/build.py 2>&1 | tee /Users/lin/Doubao/chats/2026-11-06/new-chat/build-app.log
```

## 前置条件

- [ ] Xcode 26 + MetalToolchain（`xcodebuild -downloadComponent MetalToolchain`）
- [ ] Rust 1.99（x86_64-apple-darwin）
- [ ] Homebrew 在 `/usr/local`（Intel）
- [ ] brew libpng 链接正常：`brew unlink libpng && brew link libpng`
- [ ] SteamCMD：`brew install steamcmd`（cask）

## 常见坑（之前踩过）

1. **quickjs-ng `JSInterruptHandler` 签名**：`ScriptEngine.cpp:1289` 从 `JSRuntime*` 改为 `JSContext*`
2. **SteamCMD 架构检测**：`hw.cputype` 返回 7，要 OR 上 `0x01000000`
3. **brew libpng 符号链接断了**：`brew unlink libpng && brew link libpng`
4. **OCLP / macOS 26**：可能需要额外签名处理
5. **打包**：`python3 scripts/package.py` → 输出 `WallpaperMachine-1.9.2-x86_64.dmg`

## 编译完验证

- [ ] app 能启动
- [ ] 设置里有「优先使用独立显卡」开关
- [ ] 壁纸库能切壁纸
- [ ] dmg 在 `build/Build/Products/Debug/`
