import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_music/widgets/navigation_bar.dart';
import 'package:ai_music/widgets/main_content.dart';
import 'package:ai_music/widgets/player_bar.dart';
import 'package:ai_music/services/music_player.dart';
import 'package:ai_music/services/playlist_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainContent(index: 0), // 首页/发现
    const MainContent(index: 1), // 推荐
    const MainContent(index: 2), // 歌单
    const MainContent(index: 3), // 我的音乐
    const MainContent(index: 4), // 本地音乐
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          NavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // 主内容区域
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      // 底部播放控制栏
      bottom: const PlayerBar(),
    );
  }
}