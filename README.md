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
