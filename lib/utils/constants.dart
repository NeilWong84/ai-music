// 常量定义
class AppConstants {
  // 应用名称
  static const String appName = 'AI Music Player';
  
  // 颜色常量
  static const Color primaryColor = Color(0xFF1DB954); // Spotify绿色
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF181818);
  static const Color cardColor = Color(0xFF282828);
  static const Color textColorPrimary = Color(0xFFFFFFFF);
  static const Color textColorSecondary = Color(0xB3FFFFFF);
  static const Color dividerColor = Color(0x1FFFFFFF);
  
  // 尺寸常量
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  
  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  
  // 网络相关
  static const String baseUrl = 'https://api.example.com'; // 示例API地址
  
  // 本地存储键名
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserAvatar = 'user_avatar';
  static const String keyPlayHistory = 'play_history';
  static const String keyFavoriteSongs = 'favorite_songs';
  static const String keyPlayMode = 'play_mode';
  static const String keyVolume = 'volume';
  
  // 播放模式
  static const String playModeSequential = 'sequential';
  static const String playModeLoop = 'loop';
  static const String playModeShuffle = 'shuffle';
}

// 尺寸工具类
class Dimens {
  static const double appBarHeight = 60.0;
  static const double playerBarHeight = 70.0;
  static const double navigationBarWidth = 200.0;
  static const double albumCoverSize = 50.0;
  static const double playlistCoverSize = 140.0;
  static const double songListItemHeight = 60.0;
}