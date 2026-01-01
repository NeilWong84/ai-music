import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_player.dart';
import '../models/song.dart';
import 'dart:math' as math;

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, musicPlayer, child) {
        final currentSong = musicPlayer.currentSong;
        final isPlaying = musicPlayer.playStatus == PlayStatus.playing;

        // 根据播放状态控制旋转
        if (isPlaying) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          _rotationController.stop();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5E6D3),
          body: Stack(
            children: [
              // 主体内容
              Row(
                children: [
                  // 左侧：唱片区域
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildVinylPlayer(currentSong, isPlaying),
                    ),
                  ),
                  // 右侧：歌词区域
                  Expanded(
                    flex: 3,
                    child: _buildLyricsSection(currentSong),
                  ),
                ],
              ),
              // 顶部左侧：返回按钮
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF333333),
                    size: 32,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // 顶部右侧：窗口控制按钮
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.minimize,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.crop_square,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // 底部播放控制栏
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(musicPlayer, currentSong),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建黑胶唱片播放器
  Widget _buildVinylPlayer(Song? song, bool isPlaying) {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈装饰
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 旋转的黑胶唱片
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.grey[800]!,
                    Colors.black,
                  ],
                  stops: const [0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 唱片同心圆纹理
                  for (int i = 0; i < 8; i++)
                    Container(
                      width: 260 - (i * 30.0),
                      height: 260 - (i * 30.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                  // 中心封面
                  ClipOval(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: song?.albumArt.isNotEmpty == true
                          ? Image.network(
                              song!.albumArt,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.music_note,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.music_note,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 唱片中心圆点
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.grey[600]!, width: 2),
            ),
          ),
          // 唱针
          Positioned(
            top: 20,
            right: 40,
            child: Transform.rotate(
              angle: isPlaying ? -0.3 : -0.1,
              alignment: Alignment.topRight,
              child: Container(
                width: 8,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // QQ音乐小标识
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF31C27C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Q',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建歌词区域
  Widget _buildLyricsSection(Song? song) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 歌曲信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                song?.title ?? '未知歌曲',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF6B6B)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            song?.artist ?? '未知艺术家',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          // 歌词内容
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLyricLine('好多天都看不完', false),
                  _buildLyricLine('刚才吻了你一下你也喜欢吗', true),
                  _buildLyricLine('不然怎么一直牵我的手不放', false),
                  _buildLyricLine('你说你好想带我回去你的家乡', false),
                  _buildLyricLine('绿瓦红砖', false),
                  _buildLyricLine('柳树和青苔', false),
                  _buildLyricLine('过去和现在', false),
                  _buildLyricLine('都一个样', false),
                  _buildLyricLine('你说你也会这样', false),
                  const SizedBox(height: 20),
                  // 歌词控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Text(
                              '按 ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'ctrl',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ' + ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Icon(Icons.arrow_upward,
                                      size: 12, color: Colors.grey[700]),
                                ],
                              ),
                            ),
                            Text(
                              '、',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'ctrl',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ' + ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Icon(Icons.arrow_downward,
                                      size: 12, color: Colors.grey[700]),
                                ],
                              ),
                            ),
                            Text(
                              ' 缩放歌词 ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Icon(Icons.close, size: 16),
                          ],
                        ),
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
  }

  // 构建歌词行
  Widget _buildLyricLine(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? const Color(0xFFFF6B6B) : const Color(0xFF666666),
          fontSize: isActive ? 22 : 18,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 构建底部控制栏
  Widget _buildBottomControls(MusicPlayer player, Song? song) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧歌曲信息
          Expanded(
            child: Row(
              children: [
                // 小封面
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: song?.albumArt.isNotEmpty == true
                        ? Image.network(
                            song!.albumArt,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.music_note, size: 30);
                            },
                          )
                        : const Icon(Icons.music_note, size: 30),
                  ),
                ),
                const SizedBox(width: 15),
                // 歌名和艺术家
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song?.title ?? '未知歌曲',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song?.artist ?? '未知艺术家',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 喜欢按钮
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: const Color(0xFF666666),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  color: const Color(0xFF666666),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  color: const Color(0xFF666666),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // 中间播放控制
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 播放按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment),
                      color: const Color(0xFF666666),
                      iconSize: 20,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      color: const Color(0xFF333333),
                      iconSize: 28,
                      onPressed: () => player.playPrevious(),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          player.playStatus == PlayStatus.playing
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          if (player.playStatus == PlayStatus.playing) {
                            player.pause();
                          } else {
                            player.play();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      color: const Color(0xFF333333),
                      iconSize: 28,
                      onPressed: () => player.playNext(),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.lyrics_outlined),
                      color: const Color(0xFF666666),
                      iconSize: 20,
                      onPressed: () {},
                    ),
                  ],
                ),
                // 进度条
                Row(
                  children: [
                    Text(
                      _formatDuration(player.position),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: player.duration.inMilliseconds > 0
                            ? player.position.inMilliseconds /
                                player.duration.inMilliseconds
                            : 0.0,
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds:
                                (player.duration.inMilliseconds * value)
                                    .round(),
                          );
                          player.seek(newPosition);
                        },
                        activeColor: const Color(0xFFFF6B6B),
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                    Text(
                      _formatDuration(player.duration),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 右侧音量和其他控制
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 音量控制
                IconButton(
                  icon: Icon(
                    player.volume > 0.5
                        ? Icons.volume_up
                        : player.volume > 0
                            ? Icons.volume_down
                            : Icons.volume_off,
                  ),
                  color: const Color(0xFF666666),
                  iconSize: 20,
                  onPressed: () {},
                ),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: player.volume,
                    onChanged: (value) => player.setVolume(value),
                    activeColor: const Color(0xFF666666),
                    inactiveColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 10),
                // 播放模式
                IconButton(
                  icon: Icon(
                    player.playMode == PlayMode.sequential
                        ? Icons.repeat
                        : player.playMode == PlayMode.loop
                            ? Icons.repeat_one
                            : Icons.shuffle,
                  ),
                  color: const Color(0xFF666666),
                  iconSize: 20,
                  onPressed: () {
                    PlayMode newMode;
                    switch (player.playMode) {
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
                    player.setPlayMode(newMode);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.queue_music),
                  color: const Color(0xFF666666),
                  iconSize: 20,
                  onPressed: () {},
                ),
                // 评论按钮
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '评',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 免流量按钮
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diamond_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '免',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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