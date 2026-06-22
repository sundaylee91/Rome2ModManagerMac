# Rome2 Mod Manager Mac

Mac 版 Rome 2 Total War MOD 管理器。

## 功能

- 🔍 自动扫描 Steam Workshop MOD（.pack 文件）
- ✅ 勾选启用/禁用 MOD
- 📝 一键生成 `user.script.txt`
- ↔️ 拖拽排序 MOD 加载顺序
- ✏️ 双击重命名 MOD
- 🩺 路径诊断工具

## 系统要求

- macOS 15.0+
- Xcode 16.0+
- Rome 2 Total War（Mac 版）

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| `⌘R` | 扫描 Workshop MOD |
| `⌘S` | 写入 user.script.txt |

## 构建

```bash
git clone https://github.com/sundaylee91/Rome2ModManagerMac.git
cd Rome2ModManagerMac
open Rome2ModManagerMac.xcodeproj
```

然后在 Xcode 中：
1. 选择 **Product → Run** 或按 `⌘R`
2. 首次运行需在 **Signing & Capabilities** 配置签名

## 路径说明

- **Workshop MOD**: `~/Library/Application Support/Steam/steamapps/workshop/content/214950/`
- **user.script.txt**: `~/Library/Application Support/Feral Interactive/Rome 2/data/user.script.txt`

## 许可证

MIT License
