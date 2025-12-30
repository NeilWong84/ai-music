import 'package:flutter/material.dart';

class SideNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SideNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 应用标题
          Container(
            height: 60,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'AI Music',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 导航项
          Expanded(
            child: ListView(
              children: [
                _buildNavItem('发现', 0, currentIndex, onTap),
                _buildNavItem('推荐', 1, currentIndex, onTap),
                _buildNavItem('歌单', 2, currentIndex, onTap),
                _buildNavItem('我的音乐', 3, currentIndex, onTap),
                _buildNavItem('本地音乐', 4, currentIndex, onTap),
              ],
            ),
          ),
          // 用户信息区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                ),
                SizedBox(width: 8),
                Text(
                  '用户名',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index, int currentIndex, Function(int) onTap) {
    bool isSelected = index == currentIndex;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      leading: Icon(
        index == 0 ? Icons.home : 
        index == 1 ? Icons.explore : 
        index == 2 ? Icons.queue_music : 
        index == 3 ? Icons.music_note : 
        Icons.download,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      selected: isSelected,
      selectedColor: Colors.white,
      onTap: () => onTap(index),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      tileColor: isSelected ? const Color(0xFF333333) : Colors.transparent,
    );
  }
}