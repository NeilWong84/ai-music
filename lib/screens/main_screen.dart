import 'package:flutter/material.dart';
import 'package:ai_music/widgets/navigation_bar.dart' as custom_nav;
import 'package:ai_music/widgets/main_content.dart';
import 'package:ai_music/widgets/player_bar.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              // 主体内容（左右布局）
              Expanded(
                child: Row(
                  children: [
                    // 左侧导航栏
                    custom_nav.SideNavigationBar(
                      currentIndex: _selectedIndex,
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                    // 右侧内容容器（包含窗口控制按钮和页面内容）
                    Expanded(
                      child: Stack(
                        children: [
                          // 页面内容
                          _pages[_selectedIndex],
                          // 顶部可拖动区域
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: (details) {
                                windowManager.startDragging();
                              },
                              child: Container(
                                height: 40,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          // 顶部右侧窗口控制按钮容器
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildWindowControls(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 底部播放控制栏
              const PlayerBar(),
            ],
          ),
        ),
      ),
    );
  }



  // 构建窗口控制按钮
  Widget _buildWindowControls() {
    return Row(
      children: [
        // 最小化按钮
        _buildWindowButton(
          icon: Icons.minimize,
          onTap: () async {
            await windowManager.minimize();
          },
        ),
        // 最大化/还原按钮
        _buildWindowButton(
          icon: Icons.crop_square,
          onTap: () async {
            bool isMaximized = await windowManager.isMaximized();
            if (isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        // 关闭按钮
        _buildWindowButton(
          icon: Icons.close,
          onTap: () async {
            await windowManager.close();
          },
          isClose: true,
        ),
      ],
    );
  }

  // 构建单个窗口按钮
  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isClose = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 40,
          color: Colors.transparent,
          child: Icon(
            icon,
            color: Colors.white70,
            size: 16,
          ),
        ),
      ),
    );
  }
}