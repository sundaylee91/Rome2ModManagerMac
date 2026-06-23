# 🏛️ Rome2 Mod Manager Mac

<div align="center">

**A native macOS MOD manager for Total War: ROME II**

[![Platform](https://img.shields.io/badge/platform-macOS%2015.0%2B-blue)](https://github.com/sundaylee91/Rome2ModManagerMac)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)](https://github.com/sundaylee91/Rome2ModManagerMac)

[English](#english) | [中文](#中文)

</div>

---

<a name="english"></a>

## 📖 Introduction

Rome2 Mod Manager Mac is a native macOS MOD manager purpose-built for **Total War: ROME II**.

Crafted with SwiftUI and seamlessly adapted to macOS design conventions, it lets you manage your Steam Workshop MODs effortlessly: **scan, enable/disable, reorder, rename, and launch the game** — all from one elegant interface.

| Pain Point | Vanilla Solution | This Tool |
|------------|------------------|------------|
| Managing MODs requires manual editing of `user.script.txt` | The official launcher's MOD manager is Windows-only | ✅ Visual checkboxes + auto-generate script |
| MOD filenames are unreadable (e.g. `2532655874`) | Must look up on Workshop page | ✅ Preview thumbnails + custom rename |
| Load order is hard to control | Manually reorder lines in a text file | ✅ Drag-and-drop reordering, WYSIWYG |

---

## ✨ Features

### Core

- 🔍 **Auto Scan** — Automatically detects Steam Workshop directory and scans all `.pack` MOD files
- ✅ **One-Click Enable** — Check/uncheck to enable or disable MODs instantly
- 📝 **Auto-Generate Script** — Automatically writes `user.script.txt` based on your selection — no manual editing
- 🚀 **Launch Game** — Built-in one-click game launcher, automatically saves script before launching
- ↔️ **Drag & Drop Sort** — Drag MODs to adjust load order (top loads first)
- ✏️ **Custom Rename** — Double-click any MOD to rename it; names persist across restarts
- 🖼️ **Preview Thumbnails** — Auto-scans MOD folders for preview images, visible during rename too

### Advanced

- 🌐 **Bilingual UI** — Supports Chinese / English, or auto-follow system language
- ⚙️ **Custom Paths** — Customizable Workshop directory, `user.script.txt` path, and Rome2.app path
- 🩺 **Diagnostics** — Built-in path diagnostics to quickly troubleshoot "MOD not found" or "cannot write script" issues
- 💾 **Data Persistence** — Enabled list, load order, and custom names are all persisted via UserDefaults — survive restarts
- 🔔 **Toast Notifications** — Real-time feedback for all operations

---

## 🖥️ System Requirements

| Item | Requirement |
|------|-------------|
| **OS** | macOS 15.0 (Sequoia) or later |
| **Dev Tools** | Xcode 16.0+ (build only) |
| **Game** | Total War: ROME II — Mac Edition (Steam) |

---

## 🚀 Quick Start

### Direct Download (Recommended)

> Grab the latest `.app` from the [Releases](https://github.com/sundaylee91/Rome2ModManagerMac/releases) page and drag it into `/Applications`.

### Build from Source

```bash
git clone https://github.com/sundaylee91/Rome2ModManagerMac.git
cd Rome2ModManagerMac
open Rome2ModManagerMac.xcodeproj
```

In Xcode:
1. Configure your development Team under **Signing & Capabilities**
2. Press `⌘R` to build and run

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘R` | Scan Workshop MODs |
| `⌘S` | Write `user.script.txt` |
| `⌘Enter` | Launch Game |
| `↩` | Confirm Rename |

---

## 📂 File Paths

| Purpose | Default Path |
|---------|--------------|
| **Workshop MOD Directory** | `~/Library/Application Support/Steam/steamapps/workshop/content/214950/` |
| **user.script.txt** | `~/Library/Application Support/Feral Interactive/Rome 2/data/user.script.txt` |
| **Game .app** | Auto-detected (Steam) or `~/Library/Application Support/Steam/steamapps/common/Total War ROME II/` |

> All paths can be customized in the **Settings** panel.

---

## 🏗️ Architecture

```
Rome2ModManagerMac/
├── Models/
│   └── ModItem.swift              # MOD data model
├── ViewModels/
│   └── ModListViewModel.swift     # Main ViewModel (MVVM)
├── Services/
│   ├── AppSettings.swift          # UserDefaults persistence
│   └── ModFileManager.swift       # File scanning & script generation
├── Utils/
│   ├── LocalizationManager.swift  # Multi-language manager
│   └── ImageThumbnailCache.swift  # Thumbnail image cache
├── ContentView.swift              # Main UI (SwiftUI)
├── AboutView.swift                # About window
├── AppInfo.swift                  # Version & copyright info
└── Rome2ModManagerMacApp.swift    # App entry point
```

| Layer | Technology |
|-------|------------|
| **UI** | SwiftUI (native macOS style) |
| **Architecture** | MVVM (`@ObservableObject` + `@EnvironmentObject`) |
| **Persistence** | `UserDefaults` (enabled list / order / custom names) |
| **File I/O** | `FileManager` |
| **Image Processing** | `AppKit.NSImage` + in-memory cache |

### Data Storage

All user data is persisted via `UserDefaults`:

| Key | Type | Purpose |
|-----|------|---------|
| `mod_display_names` | `[String: String]` | Custom MOD names (~10 KB for 100 MODs) |
| `custom_workshop_path` | `String` | Custom Workshop path |
| `custom_user_script_path` | `String` | Custom script path |
| `custom_game_path` | `String` | Custom game .app path |

---

## 🧭 Usage Guide

### Typical Workflow

```
1. Launch App → Auto-scans Workshop MODs
2. Check desired MODs → Drag to adjust order
3. Click a MOD to see its preview thumbnail
4. Double-click the pencil icon → Rename to something readable
5. Press ⌘Enter → Auto-writes script & launches game ✅
```

### Renaming MODs

- **How**: Select a MOD → click the pencil icon (or double-click the row)
- **Effect**: Only changes the display name in the manager; `.pack` files are untouched
- **Persistence**: Names survive app restarts, system reboots — permanently saved
- **Reset**: Settings panel → Reset Defaults → Clear all custom names

### Settings Panel

Click the ⚙️ toolbar icon to open settings:

- **UI Language**: Chinese / English / Auto
- **Game Path**: Custom Rome2.app location (auto-detects Steam install by default)
- **Workshop Directory**: Custom MOD scan directory
- **user.script.txt Path**: Custom script output location
- **Diagnostics**: Check path statuses for quick troubleshooting

---

## 📄 License

This project is open-sourced under the **MIT License**.

Copyright © 2026 Sunday Lee

---

## 🙏 Acknowledgments

- [Total War: ROME II](https://www.totalwar.com/games/rome-ii/) — Creative Assembly
- Steam Workshop platform
- SwiftUI & AppKit community

---

<div align="center">

⭐ If this project helps you, consider giving it a Star!

[🐛 Report Bug](https://github.com/sundaylee91/Rome2ModManagerMac/issues) · [🔧 Contribute](https://github.com/sundaylee91/Rome2ModManagerMac/pulls)

</div>

---

<br>
<br>

---

<a name="中文"></a>

# 🏛️ Rome2 Mod Manager Mac

<div align="center">

**macOS 版《Total War: ROME II》MOD 管理器**

[![Platform](https://img.shields.io/badge/platform-macOS%2015.0%2B-blue)](https://github.com/sundaylee91/Rome2ModManagerMac)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)](https://github.com/sundaylee91/Rome2ModManagerMac)

</div>

---

## 📖 简介

Rome2 Mod Manager Mac 是一个专为 macOS 平台打造的 **Total War: ROME II** MOD 管理器。

原生 SwiftUI 构建，完美适配 macOS 设计风格，让你轻松管理 Steam Workshop 下载的 MOD：**扫描、启用、排序、重命名、一键启动游戏**，全部在优雅的界面中完成。

| 痛点 | 原生方案 | 本工具 |
|------|----------|--------|
| 管理 MOD 需手动编辑 `user.script.txt` | 官方启动器的 MOD 管理器仅 Windows 有 | ✅ 可视化勾选 + 自动生成脚本 |
| MOD 文件名不可读（如 `2532655874`） | 只能去 Workshop 页面查看 | ✅ 扫描预览图 + 自定义重命名 |
| 加载顺序难管理 | 手动调整文件顺序 | ✅ 拖拽排序，所见即所得 |

---

## ✨ 功能特性

### 核心功能

- 🔍 **自动扫描** — 自动检测 Steam Workshop 目录，扫描所有 `.pack` MOD 文件
- ✅ **一键启用** — 勾选/取消勾选即可启用或禁用 MOD
- 📝 **自动生成脚本** — 根据当前选择自动生成 `user.script.txt`，无需手动编辑
- 🚀 **启动游戏** — 内置一键启动 Rome 2，自动先保存脚本再启动
- ↔️ **拖拽排序** — 拖拽 MOD 调整加载顺序（上面先加载）
- ✏️ **自定义重命名** — 双击 MOD 即可重命名，名称永久保存（重启不丢失）
- 🖼️ **预览图片** — 自动扫描 MOD 文件夹中的预览图，重命名时也能看到

### 高级功能

- 🌐 **双语界面** — 支持中文 / English，也可设为自动跟随系统语言
- ⚙️ **路径自定义** — 支持自定义 Workshop 目录、`user.script.txt` 路径、Rome2.app 路径
- 🩺 **诊断工具** — 内置路径诊断，快速排查「找不到 MOD」「无法写入」等问题
- 💾 **数据持久化** — 启用列表、加载顺序、自定义名称全部持久化，重启不丢
- 🔔 **Toast 通知** — 操作结果实时反馈

---

## 🖥️ 系统要求

| 项目 | 要求 |
|------|------|
| **操作系统** | macOS 15.0 (Sequoia) 或更高 |
| **开发工具** | Xcode 16.0+ (仅构建需要) |
| **游戏** | Total War: ROME II — Mac 版 (Steam) |

---

## 🚀 快速开始

### 直接下载（推荐）

> 从 [Releases](https://github.com/sundaylee91/Rome2ModManagerMac/releases) 页面下载最新 `.app`，拖入 `/Applications` 即可使用。

### 从源码构建

```bash
git clone https://github.com/sundaylee91/Rome2ModManagerMac.git
cd Rome2ModManagerMac
open Rome2ModManagerMac.xcodeproj
```

在 Xcode 中：
1. 在 **Signing & Capabilities** 中配置你的开发 Team
2. 按 `⌘R` 编译运行

---

## ⌨️ 快捷键

| 快捷键 | 功能 |
|--------|------|
| `⌘R` | 扫描 Workshop MOD |
| `⌘S` | 写入 `user.script.txt` |
| `⌘Enter` | 启动游戏 |
| `↩` | 重命名确认 |

---

## 📂 文件路径说明

| 用途 | 默认路径 |
|------|----------|
| **Workshop MOD 目录** | `~/Library/Application Support/Steam/steamapps/workshop/content/214950/` |
| **user.script.txt** | `~/Library/Application Support/Feral Interactive/Rome 2/data/user.script.txt` |
| **游戏 .app** | 自动检测 (Steam) 或 `~/Library/Application Support/Steam/steamapps/common/Total War ROME II/` |

> 所有路径均可在 **设置面板** 中自定义。

---

## 🏗️ 技术架构

```
Rome2ModManagerMac/
├── Models/
│   └── ModItem.swift              # MOD 数据模型
├── ViewModels/
│   └── ModListViewModel.swift     # 主视图模型 (MVVM)
├── Services/
│   ├── AppSettings.swift          # UserDefaults 持久化
│   └── ModFileManager.swift       # 文件扫描 & 脚本生成
├── Utils/
│   ├── LocalizationManager.swift  # 多语言管理
│   └── ImageThumbnailCache.swift  # 缩略图缓存
├── ContentView.swift              # 主界面 (SwiftUI)
├── AboutView.swift                # 关于窗口
├── AppInfo.swift                  # 版本 & 版权信息
└── Rome2ModManagerMacApp.swift    # App 入口
```

| 层级 | 技术选型 |
|------|----------|
| **UI** | SwiftUI (原生 macOS 风格) |
| **架构** | MVVM (`@ObservableObject` + `@EnvironmentObject`) |
| **持久化** | `UserDefaults`（启用列表 / 排序 / 自定义名称） |
| **文件操作** | `FileManager` |
| **图片处理** | `AppKit.NSImage` + 内存缓存 |

### 数据存储

所有用户数据通过 `UserDefaults` 持久化：

| Key | 类型 | 用途 |
|-----|------|------|
| `mod_display_names` | `[String: String]` | 自定义 MOD 名称 (100个≈10KB) |
| `custom_workshop_path` | `String` | 自定义 Workshop 路径 |
| `custom_user_script_path` | `String` | 自定义脚本路径 |
| `custom_game_path` | `String` | 自定义游戏 .app 路径 |

---

## 🧭 使用指南

### 典型工作流

```
1. 启动 App → 自动扫描 Workshop MOD
2. 勾选需要的 MOD → 拖拽调整顺序
3. 点击 MOD 查看预览图
4. 双击铅笔图标 → 重命名为易读名称
5. 按 ⌘Enter → 自动写入脚本并启动游戏 ✅
```

### 重命名 MOD

- **操作**：选中 MOD → 点击右侧铅笔图标（或双击行）
- **效果**：只修改管理器中的显示名称，不影响 `.pack` 文件
- **持久化**：重命名后永久保存，重启 App / 重启电脑 都不会丢失
- **恢复**：在设置面板 → 重置默认值 → 清除所有自定义名称

### 设置面板

点击工具栏 ⚙️ 图标进入设置：

- **界面语言**：中文 / English / 自动
- **游戏路径**：自定义 Rome2.app 位置（默认自动检测 Steam 安装）
- **Workshop 目录**：自定义 MOD 扫描目录
- **user.script.txt 路径**：自定义脚本输出位置
- **诊断**：查看各项路径状态，快速排查问题

---

## 📄 许可证

本项目基于 **MIT License** 开源分发。

Copyright © 2026 Sunday Lee

---

## 🙏 致谢

- [Total War: ROME II](https://www.totalwar.com/games/rome-ii/) — Creative Assembly
- Steam Workshop 平台
- SwiftUI & AppKit 社区

---

<div align="center">

⭐ 如果这个项目对你有帮助，欢迎给个 Star！

[🐛 报告问题](https://github.com/sundaylee91/Rome2ModManagerMac/issues) · [🔧 贡献代码](https://github.com/sundaylee91/Rome2ModManagerMac/pulls)

</div>
