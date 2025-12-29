import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_player.dart';
import '../models/song.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer<MusicPlayer>(
        builder: (context, musicPlayer, child) {
          final currentSong = musicPlayer.currentSong;
          return SafeArea(
            child: Column(
              children: [
                // 顶部导航栏
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        '正在播放',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // 专辑封面
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: const Color(0xFF3A3A3A),
                          child: const Icon(
                            Icons.music_note,
                            size: 100,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 歌曲信息
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentSong?.title ?? '未知歌曲',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong?.artist ?? '未知艺术家',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // 进度条
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        '${_formatDuration(musicPlayer.position)} / ${_formatDuration(musicPlayer.duration)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Slider(
                        value: musicPlayer.duration.inMilliseconds > 0
                            ? musicPlayer.position.inMilliseconds /
                                musicPlayer.duration.inMilliseconds
                            : 0.0,
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (musicPlayer.duration.inMilliseconds * value).round(),
                          );
                          musicPlayer.seek(newPosition);
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                // 控制按钮
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.repeat,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                PlayMode newMode;
                                switch (musicPlayer.playMode) {
                                  case PlayMode.sequential:
                                    newMode = PlayMode.loop;
                                    break;
                                  case PlayMode.loop:
                                    newMode = PlayMode.shuffle;
                                    break;
                                  case PlayMode.shuffle:
                                    newMode = PlayMode.sequential;
                                    break;
                                }
                                musicPlayer.setPlayMode(newMode);
                              },
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  musicPlayer.playStatus == PlayStatus.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: const Color(0xFF1DB954),
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (musicPlayer.playStatus == PlayStatus.playing) {
                                    musicPlayer.pause();
                                  } else {
                                    musicPlayer.play();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.shuffle,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}