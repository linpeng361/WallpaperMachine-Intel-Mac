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
