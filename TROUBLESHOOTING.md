# 问题排查指南

## 依赖安装问题

### 问题：`just_audio_macos` 包找不到

**错误信息**：
```
Because ai_music depends on just_audio_macos any which doesn't exist (could not find package
just_audio_macos at https://pub.dev), version solving failed.
```

**解决方案**：

1. **使用 Flutter 的平台特定依赖机制**：
   - Flutter 会根据目标平台自动解析适当的依赖
   - 运行 `flutter pub get` 时，Flutter 会自动选择适用于当前平台的依赖

2. **确保已启用桌面支持**：
   ```
   flutter config --enable-windows-desktop
   ```

3. **清理缓存并重新获取依赖**：
   ```
   flutter clean
   flutter pub cache repair
   flutter pub get
   ```

4. **针对特定平台运行**：
   - Windows: `flutter run -d windows`
   - 这样 Flutter 会只加载 Windows 相关的依赖

### 问题：依赖版本冲突

**解决方案**：
1. 更新到最新的 Flutter 和依赖版本
2. 运行 `flutter pub upgrade` 来升级所有依赖到兼容版本

### 问题：网络连接问题

**解决方案**：
1. 检查网络连接
2. 如果在某些地区，可能需要配置镜像源：
   ```
   flutter config --pub-hosted-url https://pub.flutter-io.cn
   flutter config --storage-bucket https://storage.flutter-io.cn
   ```

## 桌面应用构建问题

### Windows 构建问题

1. **确保安装了 Visual Studio Build Tools 或 Visual Studio**
   - 需要 MSVC 工具链
   - 需要 Windows SDK

2. **启用开发者模式**（如果需要）
   - 在 Windows 设置中启用开发者模式

## 项目配置说明

### 依赖说明

本项目使用以下关键依赖：

- `just_audio`: 核心音频播放库
- `audio_service`: 后台音频服务
- `just_audio_windows`: Windows 平台音频支持
- `just_audio_linux`: Linux 平台音频支持
- `just_audio_macos`: macOS 平台音频支持

这些平台特定的依赖会在构建时根据目标平台自动选择。

### 项目结构

```
lib/
├── main.dart           # 应用入口
├── models/             # 数据模型
│   └── song.dart       # 歌曲数据模型
├── screens/            # 页面组件
│   ├── main_screen.dart        # 主屏幕
│   ├── player_screen.dart      # 播放器屏幕
│   └── search_screen.dart      # 搜索页面
├── services/           # 业务逻辑服务
│   ├── music_player.dart       # 音乐播放器管理器
│   └── playlist_service.dart   # 播放列表和收藏服务
├── utils/              # 工具类
│   └── constants.dart  # 常量定义
└── widgets/            # 可复用UI组件
    ├── navigation_bar.dart     # 左侧导航栏
    ├── main_content.dart       # 主内容区域
    ├── player_bar.dart         # 底部播放控制栏
    └── song_item.dart          # 歌曲列表项组件
```

## 运行应用

### 开发模式
```
flutter run -d windows
```

### 构建桌面应用
```
flutter build windows
```

构建的可执行文件位于 `build/windows/runner/Release/` 目录。

## 环境要求

- Flutter SDK >= 3.3.0
- Dart SDK >= 3.0.0
- Windows 10 或更高版本（用于Windows桌面支持）
- Visual Studio 或 Build Tools（包含MSVC和Windows SDK）