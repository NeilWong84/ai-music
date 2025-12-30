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
- 🆕 **首页轮播图**：使用在线随机图片，支持自动轮播
- 🖼️ **动态图片加载**：所有图片占位符都使用在线随机图片
- ⚡ **流畅加载体验**：图片加载过程显示加载指示器
- 🛡️ **错误处理**：图片加载失败时显示默认图标
- 🎵 **网络音源**：集成免费音乐API，提供真实的在线音乐播放
- 🔍 **实时搜索**：支持搜索网络音乐库中的歌曲
- 📻 **推荐系统**：获取最新音乐和热门歌单推荐
- ✨ **丰富动画** ⭐（新增）：
  - 加载动画：旋转音符、脉冲效果、三点跳跃
  - 播放/暂停动画：平滑的图标切换和缩放效果
  - 旋转唱片：播放时唱片自动旋转
  - 音频波形：实时显示音频播放状态
  - 脉冲圆环：播放时的动态脉冲效果

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

### 音乐API服务

项目集成了多个免费音乐API，提供在线音乐播放功能：

1. **网易云音乐API** （默认）
   - 基于URL: `https://netease-cloud-music-api-rust-psi.vercel.app`
   - 支持功能：
     - 推荐歌曲：`/personalized/newsong`
     - 热门排行：`/top/list`
     - 歌曲搜索：`/search`
     - 播放URL：`/song/url`
     - 歌单详情：`/playlist/detail`
     - 推荐歌单：`/personalized`

2. **Jamendo API** （备用）
   - 提供免费CC授权音乐
   - 支持免审查商用
   - API: `https://api.jamendo.com/v3.0/tracks/`

### 使用示例

```dart
// 创廾API服务实例
final apiService = MusicApiService();

// 获取推荐歌曲（自动使用缓存）
final songs = await apiService.getRecommendSongs(limit: 30);

// 搜索歌曲（自动缓存结果）
final results = await apiService.searchSongs('周杰伦', limit: 50);

// 获取歌曲详情和播放URL（自动缓存URL）
final songDetail = await apiService.getSongDetail(songId);

// 获取热门排行榜
final topSongs = await apiService.getTopSongs(limit: 50);

// 获取推荐歌单（自动缓存）
final playlists = await apiService.getRecommendPlaylists(limit: 10);

// 缓存管理
import 'package:ai_music/services/cache_service.dart';

// 查看缓存统计
final stats = await CacheService.getCacheStats();
print('缓存数量: ${stats['count']}, 大小: ${stats['sizeKB']}KB');

// 清除所有缓存
await CacheService.clearAllCache();
```

### 注意事项

- 本项目使用的API仅供学习和测试使用
- 商业使用请遵守相关API的使用协议
- 建议使用自己的API服务或正版音乐平台API
- API请求可能因网络问题失败，已做错误处理

### 网络优化功能

**自动重试机制**
- 请求超时后自动重试（最多2次）
- 失败自动切换到备用API地址
- 5秒超时限制，快速失败快速切换

**多个API备用地址**
- 网易云音乐API（7个备用地址）
  - 5个Vercel部署地址
  - 2个国内稳定API服务
- 自动切换机制，提高可用性

**本地缓存机制** ✨ （新增）
- 自动缓存API响应数据（1小时有效期）
- 缓存内容：
  - 推荐歌曲列表
  - 推荐歌单列表
  - 搜索结果（按关键词）
  - 歌曲播放URL
- 减少网络请求，提升响应速度
- 缓存自动管理，过期自动更新

**离线备用方案**
- 网络完全失败时使用模拟数据
- 提供10首流行歌曲和10个热门歌单
- 确保应用始终可用

**数据加载优先级**

应用会按以下顺序加载数据：
1. ✅ **本地缓存** - 最快，立即显示
2. 🌐 **网络请求** - 自动重试并切换API
3. 📡 **离线数据** - 网络失败时使用

**解决网络超时问题**

如果遇到网络超时问题，应用会：
1. 自动重试并切换API地址
2. 失败后自动使用离线数据
3. 显示模拟歌曲和歌单
4. 用户可以浏览，但无法播放（需要真实播放URL）

此项目为音乐播放器的框架实现，实际使用时需要：

1. 集成音乐API服务 ✅ （已完成）
2. 根据需要调整UI主题和样式
3. 实现用户认证系统（可选）

## 许可证

此项目为演示用途，可自由使用和修改。