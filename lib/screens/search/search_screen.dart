import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song.dart';
import '../../services/playlist_service.dart';
import '../../services/music_api_service.dart';
import '../../widgets/song_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MusicApiService _apiService = MusicApiService();
  List<Song> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // 使用真实API搜索
      final results = await _apiService.searchSongs(query, limit: 50);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('搜索失败: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 搜索框
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索歌曲、歌手、专辑...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _performSearch,
                ),
              ),
              const SizedBox(height: 16),
              // 搜索结果或推荐内容
              Expanded(
                child: _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _searchResults.isEmpty
                        ? _buildSearchRecommendations()
                        : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门搜索',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip('流行'),
            _buildChip('摇滚'),
            _buildChip('民谣'),
            _buildChip('电子'),
            _buildChip('古典'),
            _buildChip('说唱'),
            _buildChip('爵士'),
            _buildChip('乡村'),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          '搜索历史',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Song>>(
          future: Provider.of<PlaylistService>(context).getPlayHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final history = snapshot.data ?? [];
              return Column(
                children: history.take(5).map((song) {
                  return ListTile(
                    title: Text(
                      song.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(
                      Icons.history,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _searchController.text = song.title;
                      _performSearch(song.title);
                    },
                  );
                }).toList(),
              );
            } else {
              return const Text(
                '暂无搜索历史',
                style: TextStyle(color: Colors.grey),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF3A3A3A),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '搜索结果 (${_searchResults.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final song = _searchResults[index];
              return SongItem(
                song: song,
                onTap: () {
                  // 播放歌曲
                },
                onPlayNext: () {
                  // 添加到下一首播放
                },
                onAddToPlaylist: () {
                  // 添加到播放列表
                },
                onAddToFavorites: () {
                  // 添加到收藏
                },
              );
            },
          ),
        ),
      ],
    );
  }
}