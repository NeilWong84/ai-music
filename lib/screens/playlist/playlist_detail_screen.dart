import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/music_player.dart';
import '../../widgets/song_item.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;
  final List<Song> songs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlistName),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF2A2A2A),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                '播放列表为空',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return SongItem(
                  song: song,
                  onTap: () {
                    // 添加到播放队列并播放
                    final musicPlayer = Provider.of<MusicPlayer>(context, listen: false);
                    musicPlayer.setPlaylist(songs, initialIndex: index);
                    musicPlayer.play();
                  },
                  onPlayNext: () {
                    // 添加到下一首播放
                    final musicPlayer = Provider.of<MusicPlayer>(context, listen: false);
                    musicPlayer.addSongToPlaylist(song);
                  },
                  onAddToPlaylist: () {
                    // 添加到其他播放列表
                    _showAddToPlaylistDialog(context, song);
                  },
                  onAddToFavorites: () {
                    // 添加到收藏
                  },
                );
              },
            ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加到播放列表'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('我喜欢的音乐'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // 添加到"我喜欢的音乐"播放列表
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('新建播放列表'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // 创建新播放列表
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
}