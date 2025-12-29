# AI Music Player 项目结构说明

## 项目概述
AI Music Player 是一个使用 Flutter 开发的跨平台音乐播放器应用，支持桌面端（Windows、macOS、Linux）和移动端（iOS、Android）。

## 项目目录结构
```
ai-music/
├── lib/                    # 源代码目录
│   ├── main.dart           # 应用入口文件
│   ├── models/             # 数据模型
│   │   └── song.dart       # 歌曲数据模型
│   ├── screens/            # 页面组件
│   │   ├── main_screen.dart        # 主屏幕（包含导航和内容）
│   │   ├── player_screen.dart      # 详细播放页面
│   │   └── search_screen.dart      # 搜索页面
│   ├── services/           # 业务逻辑服务
│   │   ├── audio_service.dart      # 音频服务（后台播放）
│   │   ├── music_player.dart       # 音乐播放器管理器
│   │   └── playlist_service.dart   # 播放列表和收藏服务
│   ├── utils/              # 工具类
│   │   └── constants.dart  # 常量定义
│   └── widgets/            # 可复用UI组件
│       ├── navigation_bar.dart     # 左侧导航栏
│       ├── main_content.dart       # 主内容区域
│       ├── player_bar.dart         # 底部播放控制栏
│       └── song_item.dart          # 歌曲列表项组件
├── assets/                 # 静态资源
│   ├── images/             # 图片资源
│   ├── icons/              # 图标资源
│   └── fonts/              # 字体资源
├── test/                   # 测试文件
│   └── widget_test.dart    # 组件测试
├── pubspec.yaml            # 项目配置文件
├── README.md               # 项目说明
└── PROJECT_INFO.md         # 项目结构说明
```

## 核心功能模块

### 1. UI界面模块
- **导航栏**: 左侧导航，包含发现、推荐、歌单、我的音乐、本地音乐等选项
- **主内容区**: 根据不同页面显示相应内容
- **播放控制栏**: 底部固定播放控制区域
- **播放详情页**: 全屏播放界面，显示专辑封面和控制按钮

### 2. 音乐播放模块
- **MusicPlayer**: 核心播放管理器，处理播放、暂停、上一首、下一首等功能
- **音频服务**: 支持后台播放和系统通知控制
- **播放模式**: 支持顺序播放、单曲循环、随机播放

### 3. 数据管理模块
- **播放列表管理**: 创建、编辑、删除播放列表
- **收藏功能**: 收藏/取消收藏歌曲
- **播放历史**: 记录用户播放历史
- **本地存储**: 使用SharedPreferences存储用户偏好

### 4. 搜索功能模块
- **歌曲搜索**: 搜索歌曲、歌手、专辑
- **搜索历史**: 保存和显示搜索历史
- **热门搜索**: 显示热门搜索关键词

## 技术特点

### 状态管理
- 使用 Provider 进行状态管理
- MusicPlayer 作为 ChangeNotifier 提供播放状态
- PlaylistService 提供数据服务

### 音频处理
- Just Audio 提供音频播放功能
- 支持多种音频格式
- 音频会话管理确保与其他应用的音频协调

### UI设计
- 暗色主题，参考主流音乐应用设计
- 响应式布局，适配不同屏幕尺寸
- 流畅的动画和过渡效果

## 桌面端特性

### Windows支持
- 使用 just_audio_windows 提供音频播放支持
- 原生桌面体验
- 系统托盘集成（待实现）

### macOS支持
- 使用 just_audio_macos 提供音频播放支持
- 符合macOS设计规范

### Linux支持
- 使用 just_audio_linux 提供音频播放支持
- 适配Linux桌面环境

## 依赖说明

### 核心依赖
- `flutter`: Flutter框架
- `provider`: 状态管理
- `just_audio`: 音频播放
- `audio_service`: 后台音频服务
- `shared_preferences`: 本地数据存储
- `audio_session`: 音频会话管理
- `rxdart`: 响应式编程库

### 平台特定依赖
- `just_audio_windows`: Windows音频支持
- `just_audio_macos`: macOS音频支持
- `just_audio_linux`: Linux音频支持

### 安装依赖

在项目根目录运行：

```
flutter pub get
```

这将安装pubspec.yaml中定义的所有依赖包。

### 平台特定依赖
- `just_audio_windows`: Windows音频支持
- `just_audio_macos`: macOS音频支持
- `just_audio_linux`: Linux音频支持

### 工具依赖
- `http`: 网络请求
- `rxdart`: 响应式编程
- `path_provider`: 文件路径管理
- `flutter_svg`: SVG图标支持

## 开发建议

### 扩展功能
1. 集成音乐API服务（如网易云音乐API、QQ音乐API）
2. 添加歌词显示功能
3. 实现均衡器
4. 添加主题切换功能
5. 实现用户登录系统

### 性能优化
1. 图片懒加载
2. 音乐列表虚拟化
3. 音频预加载
4. 内存管理优化

### UI/UX改进
1. 添加加载状态
2. 优化动画效果
3. 增加手势控制
4. 适配浅色主题

## 部署说明

### 桌面端构建
- Windows: `flutter build windows`
- macOS: `flutter build macos`
- Linux: `flutter build linux`

### 移动端构建
- Android: `flutter build apk`
- iOS: `flutter build ios`

## 注意事项

1. 音乐API需要替换为实际的音乐服务API
2. 需要申请相关音乐平台的API权限
3. 遵守音乐版权相关法律法规
4. 测试时使用合法的音乐资源

## 许可证

本项目为演示项目，可自由用于学习和参考。