# AI Music Player

一个使用Flutter开发的在线听歌桌面APP，界面设计参考QQ音乐、酷我音乐等主流音乐播放器。

## 功能特性

- 音乐播放控制（播放、暂停、上一首、下一首）
- 播放模式切换（顺序播放、单曲循环、随机播放）
- 音量控制
- 播放进度控制
- 播放列表管理
- 歌曲收藏功能
- 搜索功能
- 播放历史记录
- 本地音乐管理

## 技术栈

- Flutter 3.x
- Dart
- Provider (状态管理)
- Just Audio (音频播放)
- Audio Service (后台播放服务)
- Shared Preferences (本地数据存储)

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   └── song.dart             # 歌曲模型
├── services/                 # 服务层
│   ├── audio_service.dart    # 音频服务
│   ├── music_player.dart     # 音乐播放器
│   └── playlist_service.dart # 播放列表服务
├── screens/                  # 页面
│   ├── main_screen.dart      # 主屏幕
│   ├── player_screen.dart    # 播放器屏幕
│   └── search_screen.dart    # 搜索屏幕
├── widgets/                  # 组件
│   ├── navigation_bar.dart   # 导航栏
│   ├── main_content.dart     # 主内容区
│   ├── player_bar.dart       # 播放控制栏
│   └── song_item.dart        # 歌曲列表项
└── utils/                    # 工具类
    └── constants.dart        # 常量定义
```

## 安装和运行

### 快速安装（Windows）

项目提供了自动化安装脚本，可帮助您快速安装依赖：

- Windows批处理脚本：双击 `install_dependencies.bat`
- PowerShell脚本：在PowerShell中运行 `install_dependencies.ps1`

### 安装Flutter SDK

1. 从 [Flutter官网](https://docs.flutter.dev/get-started/install/windows) 下载Windows版SDK
2. 解压到指定目录（如 `C:\src\flutter`）
3. 将 `C:\src\flutter\bin` 添加到系统PATH环境变量
4. 重新打开命令行，运行 `flutter --version` 验证安装

### 项目设置

1. 克隆或下载项目
2. 进入项目目录
3. 运行 `flutter pub get` 安装依赖
4. 启用Windows桌面支持：`flutter config --enable-windows-desktop`
5. 运行 `flutter doctor` 检查环境配置

### 运行应用

- 开发模式运行：`flutter run -d windows`
- 构建桌面应用：`flutter build windows`

### 桌面端支持

本项目支持Windows、macOS和Linux桌面平台：

- Windows: `flutter run -d windows`
- macOS: `flutter run -d macos`
- Linux: `flutter run -d linux`

## 桌面端支持

本项目支持Windows、macOS和Linux桌面平台：

- Windows: `flutter run -d windows`
- macOS: `flutter run -d macos`
- Linux: `flutter run -d linux`

## 开发说明

此项目为音乐播放器的框架实现，实际使用时需要：

1. 集成音乐API服务
2. 添加真实的音乐资源
3. 实现用户认证系统
4. 根据需要调整UI主题和样式

## 许可证

此项目为演示用途，可自由使用和修改。