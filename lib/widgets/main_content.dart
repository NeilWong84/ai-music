import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/playlist_service.dart';
import '../services/music_api_service.dart';
import '../services/mock_music_service.dart';
import '../services/music_player.dart';
import 'animations/loading_animation.dart';
import '../utils/logger.dart';

class MainContent extends StatelessWidget {
  final int index;
  const MainContent({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) ...[
              // 发现页面内容
              const _BannerSection(),
              const SizedBox(height: 20),
              const _RecommendPlaylists(),
              const SizedBox(height: 20),
              const _NewMusic(),
              const SizedBox(height: 20),
              const _RankingList(),
            ] else if (index == 1) ...[
              // 推荐页面内容
              _buildRecommendContent(),
            ] else if (index == 2) ...[
              // 歌单页面内容
              _buildPlaylistContent(context),
            ] else if (index == 3) ...[
              // 我的音乐页面内容
              _buildMyMusicContent(context),
            ] else if (index == 4) ...[
              // 本地音乐页面内容
              _buildLocalMusicContent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendContent() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐内容',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '这里显示推荐内容',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistContent(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的歌单',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '这里显示我的歌单',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMusicContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的音乐',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // 收藏的歌曲
          const Text(
            '收藏的歌曲',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Song>>(
            future: Provider.of<PlaylistService>(context, listen: false).getFavoriteSongs(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final favoriteSongs = snapshot.data!;
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = favoriteSongs[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF3A3A3A),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.network(
                                'https://picsum.photos/seed/favorite$index/140/100',
                                height: 100,
                                width: 140,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 100,
                                    width: 140,
                                    color: const Color(0xFF5A5A5A),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    width: 140,
                                    color: const Color(0xFF5A5A5A),
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 50,
                                      color: Colors.white30,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                '收藏歌曲',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Text('暂无收藏歌曲', style: TextStyle(color: Colors.grey));
              }
            },
          ),
          const SizedBox(height: 30),
          // 播放历史
          const Text(
            '播放历史',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Song>>(
            future: Provider.of<PlaylistService>(context, listen: false).getPlayHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final historySongs = snapshot.data!;
                return Column(
                  children: historySongs.take(5).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final song = entry.value;
                    return Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFF3A3A3A),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://picsum.photos/seed/history$index/50/50',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: const Color(0xFF5A5A5A),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5A5A5A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white30,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              } else {
                return const Text('暂无播放历史', style: TextStyle(color: Colors.grey));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocalMusicContent() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本地音乐',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '这里显示本地音乐',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSection extends StatefulWidget {
  const _BannerSection({super.key});

  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _bannerImages = [
    'https://picsum.photos/seed/banner1/800/300',
    'https://picsum.photos/seed/banner2/800/300',
    'https://picsum.photos/seed/banner3/800/300',
    'https://picsum.photos/seed/banner4/800/300',
  ];

  @override
  void initState() {
    super.initState();
    // 自动轮播
    Future.delayed(const Duration(seconds: 3), _autoPlay);
  }

  void _autoPlay() {
    if (mounted) {
      final nextPage = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), _autoPlay);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF3A3A3A),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF3A3A3A),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.white30,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // 指示器
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendPlaylists extends StatefulWidget {
  const _RecommendPlaylists({super.key});

  @override
  State<_RecommendPlaylists> createState() => _RecommendPlaylistsState();
}

class _RecommendPlaylistsState extends State<_RecommendPlaylists> {
  final MusicApiService _apiService = MusicApiService();
  List<Map<String, dynamic>> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      final playlists = await _apiService.getRecommendPlaylists(limit: 10);
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('加载推荐歌单失败', e);
      // 如果异常也无法获取mock数据，至少保证UI不会空白
      if (mounted) {
        setState(() {
          // 确保至少有mock数据
          if (_playlists.isEmpty) {
            _playlists = MockMusicService.getMockPlaylists();
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '推荐歌单',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: LoadingAnimation(
                  size: 60,
                  color: Colors.white,
                  text: '加载中...',
                ),
              ),
            )
          else if (_playlists.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  '暂无推荐歌单',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF3A3A3A),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            playlist['coverImgUrl'] ?? 'https://picsum.photos/seed/playlist$index/140/100',
                            width: 140,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 100,
                                width: 140,
                                color: const Color(0xFF5A5A5A),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                width: 140,
                                color: const Color(0xFF5A5A5A),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 50,
                                  color: Colors.white30,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist['name'] ?? '未知歌单',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (playlist['playCount'] != null)
                                Text(
                                  '${_formatPlayCount(playlist['playCount'])}次播放',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatPlayCount(int count) {
    if (count >= 100000000) {
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    } else if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }
}

class _NewMusic extends StatefulWidget {
  const _NewMusic({super.key});

  @override
  State<_NewMusic> createState() => _NewMusicState();
}

class _NewMusicState extends State<_NewMusic> {
  final MusicApiService _apiService = MusicApiService();
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNewMusic();
  }

  Future<void> _loadNewMusic() async {
    try {
      final songs = await _apiService.getRecommendSongs(limit: 10);
      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.e('加载最新音乐失败', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playSong(Song song) async {
    try {
      AppLogger.i('🎵 准备播放: ${song.title}');
      
      Song? songToPlay = song;
      
      // 如果歌曲已经有播放 URL，直接播放
      if (song.url.isEmpty) {
        AppLogger.i('ℹ️ 歌曲 URL 为空，尝试获取歌曲详情...');
        // 获取歌曲详情和播放URL
        songToPlay = await _apiService.getSongDetail(song.id);
        if (songToPlay == null || songToPlay.url.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('无法播放该歌曲: ${song.title}')),
            );
          }
          return;
        }
      }
      
      AppLogger.i('✅ 播放 URL: ${songToPlay.url}');
      
      if (mounted) {
        final player = Provider.of<MusicPlayer>(context, listen: false);
        // 设置播放列表并播放
        await player.setPlaylist([songToPlay], initialIndex: 0);
        await player.play();
        
        AppLogger.i('🎵 开始播放: ${songToPlay.title}');
      }
    } catch (e) {
      AppLogger.e('播放歌曲失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新音乐',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const SizedBox(
              height: 300,
              child: Center(
                child: LoadingAnimation(
                  size: 60,
                  color: Colors.white,
                  text: '加载最新音乐...',
                ),
              ),
            )
          else if (_songs.isEmpty)
            const SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  '暂无最新音乐',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Consumer<MusicPlayer>(
              builder: (context, player, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _songs.length > 10 ? 10 : _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final isCurrentSong = player.currentSong?.id == song.id;
                    final isPlaying = player.playStatus == PlayStatus.playing && isCurrentSong;
                    
                    return InkWell(
                      onTap: () => _playSong(song),
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isCurrentSong 
                              ? const Color(0xFF4A4A4A) 
                              : const Color(0xFF3A3A3A),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                song.albumArt.isNotEmpty 
                                    ? song.albumArt 
                                    : 'https://picsum.photos/seed/song$index/50/50',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: const Color(0xFF5A5A5A),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5A5A5A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white30,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    song.title,
                                    style: TextStyle(
                                      color: isCurrentSong 
                                          ? const Color(0xFF1DB954) 
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isCurrentSong 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // 显示播放状态指示器
                            if (isCurrentSong)
                              Icon(
                                isPlaying ? Icons.volume_up : Icons.pause,
                                color: const Color(0xFF1DB954),
                                size: 20,
                              )
                            else
                              const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  const _RankingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '排行榜',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF3A3A3A),
            ),
            child: const Center(
              child: Text(
                '排行榜内容',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}