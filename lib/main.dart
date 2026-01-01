import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_music/screens/main_screen.dart';
import 'package:ai_music/services/music_player.dart';
import 'package:ai_music/services/playlist_service.dart';
import 'package:ai_music/utils/logger.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 确保 Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  
  // 设置窗口属性
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,  // 隐藏原生标题栏
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    // 设置窗口圆角
    await windowManager.setAsFrameless();
  });
  
  // 初始化日志系统
  await AppLogger.init();
  AppLogger.i('🚀 应用启动...');
  
  // 清理旧日志（保留最近7天）
  await AppLogger.cleanOldLogs();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicPlayer()),
        Provider(create: (_) => PlaylistService()),
      ],
      child: MaterialApp(
        title: 'AI Music Player',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}