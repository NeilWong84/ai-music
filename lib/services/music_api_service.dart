import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/song.dart';

/// 音乐API服务 - 提供免费的网络音源
class MusicApiService {
  // 使用网易云音乐的公开API（非官方）- 多个备用地址
  static const List<String> _baseUrls = [
    'https://netease-cloud-music-api-jade-sigma.vercel.app',
    'https://netease-api.vercel.app',
    'https://music-api.heheda.top',
  ];
  
  // 当前使用的API索引
  int _currentUrlIndex = 0;
  
  // 获取当前BASE URL
  String get _baseUrl => _baseUrls[_currentUrlIndex];
  
  // 请求超时设置
  static const Duration _timeout = Duration(seconds: 10);
  
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

  /// 获取推荐歌曲
  Future<List<Song>> getRecommendSongs({int limit = 30}) async {
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/personalized/newsong?limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List result = data['result'] ?? [];
        
        return result.map((item) {
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
      }
    } catch (e) {
      print('获取推荐歌曲失败: $e');
    }
    return [];
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
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/search?keywords=${Uri.encodeComponent(keyword)}&limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List songs = data['result']?['songs'] ?? [];
        
        return songs.map((song) {
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
      }
    } catch (e) {
      print('搜索歌曲失败: $e');
    }
    return [];
  }

  /// 获取歌曲播放URL
  Future<String?> getSongUrl(String songId) async {
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/song/url?id=$songId',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List urls = data['data'] ?? [];
        if (urls.isNotEmpty) {
          return urls[0]['url'];
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
    try {
      final response = await _requestWithRetry(
        '$_baseUrl/personalized?limit=$limit',
      );

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List result = data['result'] ?? [];
        
        return result.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'] ?? '未知歌单',
            'coverImgUrl': item['picUrl'] ?? '',
            'playCount': item['playCount'] ?? 0,
          };
        }).toList();
      }
    } catch (e) {
      print('获取推荐歌单失败: $e');
    }
    return [];
  }

  /// 备用方案：使用免费音乐库（Jamendo）
  Future<List<Song>> getJamendoTracks({int limit = 30}) async {
    try {
      // Jamendo 免费音乐API
      final response = await http.get(
        Uri.parse(
          'https://api.jamendo.com/v3.0/tracks/?client_id=56d30c95&format=json&limit=$limit&include=musicinfo',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'],
            title: track['name'] ?? '未知歌曲',
            artist: track['artist_name'] ?? '未知歌手',
            album: track['album_name'] ?? '未知专辑',
            albumArt: track['image'] ?? '',
            url: track['audio'] ?? '',
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
