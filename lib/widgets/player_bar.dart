import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_player.dart';
import '../models/song.dart';
import '../screens/player_screen.dart';
import 'animations/player_animation.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();}

class _PlayerBarState extends State<PlayerBar> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, musicPlayer, child) {
        final currentSong = musicPlayer.currentSong;
        return Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 专辑封面 - 添加动画
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF3A3A3A),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: currentSong?.albumArt.isNotEmpty == true
                            ? Image.network(
                                currentSong!.albumArt,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.music_note,
                                    color: Colors.white30,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.music_note,
                                color: Colors.white30,
                              ),
                      ),
                    ),
                    // 播放时显示波形动画
                    if (musicPlayer.playStatus == PlayStatus.playing)
                      const Positioned(
                        bottom: 2,
                        child: WaveformAnimation(
                          isPlaying: true,
                          color: Colors.blue,
                          barCount: 3,
                          height: 15,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                // 歌曲信息 - 添加悬停效果和点击跳转
                Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                      onTap: currentSong != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlayerScreen(),
                                ),
                              );
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _isHovering
                              ? const Color(0xFF2A2A2A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentSong?.title ?? '请选择歌曲',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_isHovering && currentSong != null)
                                  const Icon(
                                    Icons.open_in_full,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSong != null
                                  ? '${currentSong.artist} - ${currentSong.album}'
                                  : '艺术家 - 专辑',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 播放控制按钮
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        musicPlayer.playPrevious();
                      },
                    ),
                    const SizedBox(width: 10),
                    PlayPauseButton(
                      isPlaying: musicPlayer.playStatus == PlayStatus.playing,
                      onPressed: () {
                        if (musicPlayer.playStatus == PlayStatus.playing) {
                          musicPlayer.pause();
                        } else {
                          musicPlayer.play();
                        }
                      },
                      size: 40,
                      color: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        musicPlayer.playNext();
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // 播放模式
                PopupMenuButton<PlayMode>(
                  icon: Icon(
                    musicPlayer.playMode == PlayMode.sequential
                        ? Icons.repeat
                        : musicPlayer.playMode == PlayMode.loop
                            ? Icons.repeat_one
                            : Icons.shuffle,
                    color: Colors.white,
                    size: 18,
                  ),
                  onSelected: (mode) {
                    musicPlayer.setPlayMode(mode);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: PlayMode.sequential,
                      child: Text('顺序播放'),
                    ),
                    const PopupMenuItem(
                      value: PlayMode.loop,
                      child: Text('单曲循环'),
                    ),
                    const PopupMenuItem(
                      value: PlayMode.shuffle,
                      child: Text('随机播放'),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // 音量控制
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(
                      width: 80,
                      child: Slider(
                        value: musicPlayer.volume,
                        onChanged: (value) {
                          musicPlayer.setVolume(value);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // 播放列表按钮
                IconButton(
                  icon: const Icon(
                    Icons.queue_music,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}