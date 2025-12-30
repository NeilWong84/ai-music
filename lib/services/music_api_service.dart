import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'mock_music_service.dart';
import 'cache_service.dart';

/// 音乐API服务 - 提供免费的网络音源
class MusicApiService {
  // 使用网易云音乐的公开API（非官方）- 多个备用地址
  static const List<String> _baseUrls = [
    // 网易云API备用地址
    'https://netease-cloud-music-api-jade-sigma.vercel.app',
    'https://netease-api.vercel.app',
    'https://music-api.heheda.top',
    'https://netease-cloud-music-api-ochre.vercel.app',
    'https://netease-cloud-music-api-rouge.vercel.app',
    // 国内备用地址（更稳定）
    'https://autumnfish.cn',
    'https://music.qier222.com',
  ];
  
  // 当前使用的API索引
  int _currentUrlIndex = 0;
  
  // 获取当前BASE URL
  String get _baseUrl => _baseUrls[_currentUrlIndex];
  
  // 请求超时设置（缩短到5秒，快速失败快速切换）
  static const Duration _timeout = Duration(seconds: 5);
  
  // 备用：使用QQ音乐API
  static const String _qqMusicBase = 'https://api.qq.jsososo.com';
  
  /// 切换到下一个API地址
  void _switchToNextUrl() {
    _currentUrlIndex = (_currentUrlIndex + 1) % _baseUrls.length;
    print('切换API地址到: $_baseUrl');
  }
  
  /// 带超时和重试的HTTP请求
  Future<http.Response?> _requestWithRetry(String url, {int maxRetries = 2}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final response = await http.get(
          Uri.parse(url),
        ).timeout(_timeout);
        
        if (response.statusCode == 200) {
          return response;
        } else {
          print('请求失败，状态码: ${response.statusCode}');
        }
      } on TimeoutException catch (e) {
        print('请求超时 (尝试 ${i + 1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          _switchToNextUrl();
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        print('请求异常 (尝试 ${i + 1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          _switchToNextUrl();
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    }
    return null;
  }

  /// 获取推荐歌曲（优先使用免费可播放的音乐）
  Future<List<Song>> getRecommendSongs({int limit = 30}) async {
    // 1. 先尝试从缓存加载
    final cachedSongs = await CacheService.getCachedRecommendSongs();
    if (cachedSongs != null && cachedSongs.isNotEmpty) {
      print('✅ 使用缓存的推荐歌曲');
      return cachedSongs;
    }

    print('🎵 正在从 Jamendo 免费音乐库获取音乐...');
    
    // 2. 优先使用 Jamendo 免费音乐（真实可播放）
    final jamendoSongs = await getJamendoTracks(limit: limit);
    if (jamendoSongs.isNotEmpty) {
      print('✅ 成功从 Jamendo 获取 ${jamendoSongs.length} 首歌曲');
      await CacheService.cacheRecommendSongs(jamendoSongs);
      return jamendoSongs;
    }
    
    // 3. Jamendo失败，尝试网易云音乐API（可能无法播放）
    try {
      print('🔄 尝试网易云音乐API...');
      final response = await _requestWithRetry(
        '$_baseUrl/personalized/newsong?limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List result = data['result'] ?? [];
        
        final songs = result.map((item) {
          final song = item['song'];
          return Song(
            id: song['id'].toString(),
            title: song['name'] ?? '未知歌曲',
            artist: (song['artists'] as List?)?.map((a) => a['name']).join('/') ?? '未知歌手',
            album: song['album']?['name'] ?? '未知专辑',
            albumArt: song['album']?['picUrl'] ?? '',
            url: '', // 需要单独获取播放URL
            duration: Duration(milliseconds: song['duration'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
        
        // 缓存成功的结果
        if (songs.isNotEmpty) {
          print('✅ 从网易云获取 ${songs.length} 首歌曲（可能需要VIP）');
          await CacheService.cacheRecommendSongs(songs);
        }
        
        return songs;
      }
    } catch (e) {
      print('⚠️ 网易云API请求失败: $e');
    }
    
    // 4. 所有网络请求失败，使用本地模拟数据（包含真实可播放URL）
    print('💾 使用本地模拟数据（Bensound 免费音乐）');
    return MockMusicService.getMockRecommendSongs();
  }

  /// 获取热门歌曲（排行榜）
  Future<List<Song>> getTopSongs({int limit = 50}) async {
    try {
      // 获取飙升榜
      final response = await _requestWithRetry(
        '$_baseUrl/top/list?idx=3',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['playlist']?['tracks'] ?? [];
        
        return tracks.take(limit).map((track) {
          return Song(
            id: track['id'].toString(),
            title: track['name'] ?? '未知歌曲',
            artist: (track['ar'] as List?)?.map((a) => a['name']).join('/') ?? '未知歌手',
            album: track['al']?['name'] ?? '未知专辑',
            albumArt: track['al']?['picUrl'] ?? '',
            url: '', // 需要单独获取播放URL
            duration: Duration(milliseconds: track['dt'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print('获取热门歌曲失败: $e');
    }
    return [];
  }

  /// 搜索歌曲
  Future<List<Song>> searchSongs(String keyword, {int limit = 30}) async {
    // 1. 先尝试从缓存加载
    final cachedResults = await CacheService.getCachedSearchResults(keyword);
    if (cachedResults != null && cachedResults.isNotEmpty) {
      print('✅ 使用缓存的搜索结果: $keyword');
      return cachedResults;
    }
    
    // 2. 缓存无效，尝试网络请求
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/search?keywords=${Uri.encodeComponent(keyword)}&limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List songs = data['result']?['songs'] ?? [];
        
        final results = songs.map((song) {
          return Song(
            id: song['id'].toString(),
            title: song['name'] ?? '未知歌曲',
            artist: (song['artists'] as List?)?.map((a) => a['name']).join('/') ?? '未知歌手',
            album: song['album']?['name'] ?? '未知专辑',
            albumArt: song['album']?['picUrl'] ?? '',
            url: '', // 需要单独获取播放URL
            duration: Duration(milliseconds: song['duration'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
        
        // 缓存成功的搜索结果
        if (results.isNotEmpty) {
          await CacheService.cacheSearchResults(keyword, results);
        }
        
        return results;
      }
    } catch (e) {
      print('搜索歌曲失败: $e');
    }
    
    // 3. 网络失败，尝试从模拟数据搜索
    print('📡 使用离线数据搜索');
    return MockMusicService.searchMockSongs(keyword);
  }

  /// 获取歌曲播放URL
  Future<String?> getSongUrl(String songId) async {
    // 1. 先尝试从缓存加载
    final cachedUrl = await CacheService.getCachedSongUrl(songId);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      print('✅ 使用缓存的歌曲URL: $songId');
      return cachedUrl;
    }
    
    // 2. 缓存无效，尝试网络请求
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/song/url?id=$songId',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List urls = data['data'] ?? [];
        if (urls.isNotEmpty) {
          final url = urls[0]['url'];
          // 缓存播放URL
          if (url != null && url.isNotEmpty) {
            await CacheService.cacheSongUrl(songId, url);
          }
          return url;
        }
      }
    } catch (e) {
      print('获取播放URL失败: $e');
    }
    return null;
  }

  /// 获取歌曲详情（包括播放URL）
  Future<Song?> getSongDetail(String songId) async {
    try {
      // 获取歌曲详细信息
      final detailResponse = await _requestWithRetry(
        '$_baseUrl/song/detail?ids=$songId',
      );

      if (detailResponse != null && detailResponse.statusCode == 200) {
        final detailData = json.decode(detailResponse.body);
        final List songs = detailData['songs'] ?? [];
        
        if (songs.isEmpty) return null;
        
        final songData = songs[0];
        
        // 获取播放URL
        final playUrl = await getSongUrl(songId);
        
        return Song(
          id: songData['id'].toString(),
          title: songData['name'] ?? '未知歌曲',
          artist: (songData['ar'] as List?)?.map((a) => a['name']).join('/') ?? '未知歌手',
          album: songData['al']?['name'] ?? '未知专辑',
          albumArt: songData['al']?['picUrl'] ?? '',
          url: playUrl ?? '',
          duration: Duration(milliseconds: songData['dt'] ?? 0),
          releaseDate: DateTime.now(),
        );
      }
    } catch (e) {
      print('获取歌曲详情失败: $e');
    }
    return null;
  }

  /// 获取歌单详情
  Future<List<Song>> getPlaylistDetail(String playlistId) async {
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/playlist/detail?id=$playlistId',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['playlist']?['tracks'] ?? [];
        
        return tracks.map((track) {
          return Song(
            id: track['id'].toString(),
            title: track['name'] ?? '未知歌曲',
            artist: (track['ar'] as List?)?.map((a) => a['name']).join('/') ?? '未知歌手',
            album: track['al']?['name'] ?? '未知专辑',
            albumArt: track['al']?['picUrl'] ?? '',
            url: '', // 需要单独获取播放URL
            duration: Duration(milliseconds: track['dt'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print('获取歌单详情失败: $e');
    }
    return [];
  }

  /// 获取推荐歌单
  Future<List<Map<String, dynamic>>> getRecommendPlaylists({int limit = 10}) async {
    // 1. 先尝试从缓存加载
    final cachedPlaylists = await CacheService.getCachedRecommendPlaylists();
    if (cachedPlaylists != null && cachedPlaylists.isNotEmpty) {
      print('✅ 使用缓存的推荐歌单');
      return cachedPlaylists;
    }
    
    // 2. 缓存无效，尝试网络请求
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/personalized?limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List result = data['result'] ?? [];
        
        final playlists = result.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'] ?? '未知歌单',
            'coverImgUrl': item['picUrl'] ?? '',
            'playCount': item['playCount'] ?? 0,
          };
        }).toList();
        
        // 缓存成功的结果
        if (playlists.isNotEmpty) {
          await CacheService.cacheRecommendPlaylists(playlists);
        }
        
        return playlists;
      }
    } catch (e) {
      print('获取推荐歌单失败，使用离线数据: $e');
    }
    
    // 3. 网络请求失败，返回模拟数据
    print('📡 使用离线模拟歌单');
    return MockMusicService.getMockPlaylists();
  }

  /// 备用方案：使用免费音乐库（Jamendo）
  Future<List<Song>> getJamendoTracks({int limit = 30}) async {
    try {
      // Jamendo 免费音乐API - 无需API key的公开接口
      final response = await http.get(
        Uri.parse(
          'https://api.jamendo.com/v3.0/tracks/?client_id=56d30c95&format=json&limit=$limit&include=musicinfo&audiodownload=mp31',
        ),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'],
            title: track['name'] ?? '未知歌曲',
            artist: track['artist_name'] ?? '未知歌手',
            album: track['album_name'] ?? '未知专辑',
            albumArt: track['album_image'] ?? track['image'] ?? '',
            url: track['audio'] ?? track['audiodownload'] ?? '',
            duration: Duration(seconds: track['duration'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print('获取Jamendo音乐失败: $e');
    }
    return [];
  }

  /// 获取免费CC音乐（Free Music Archive）
  Future<List<Song>> getFreeMusicArchiveTracks({int limit = 20}) async {
    try {
      // 这里可以集成Free Music Archive API
      // 注意：需要API key
      print('Free Music Archive API需要注册获取API key');
      return [];
    } catch (e) {
      print('获取FMA音乐失败: $e');
    }
    return [];
  }
}
