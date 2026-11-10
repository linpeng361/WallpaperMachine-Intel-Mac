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
