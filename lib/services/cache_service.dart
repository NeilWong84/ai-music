import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

/// 本地缓存服务 - 用于缓存API数据，减少网络请求
class CacheService {
  static const String _cacheKeyRecommendSongs = 'cache_recommend_songs';
  static const String _cacheKeyRecommendPlaylists = 'cache_recommend_playlists';
  static const String _cacheKeySearchPrefix = 'cache_search_';
  static const String _cacheTimePrefix = 'cache_time_';
  
  // 缓存有效期（1小时）
  static const Duration _cacheValidDuration = Duration(hours: 1);
  
  /// 检查缓存是否有效
  static Future<bool> _isCacheValid(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimePrefix$key';
    final cachedTime = prefs.getInt(timeKey);
    
    if (cachedTime == null) return false;
    
    final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cachedTime);
    final now = DateTime.now();
    
    return now.difference(cacheDateTime) < _cacheValidDuration;
  }
  
  /// 保存缓存时间
  static Future<void> _saveCacheTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timeKey = '$_cacheTimePrefix$key';
    await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// 缓存推荐歌曲
  static Future<void> cacheRecommendSongs(List<Song> songs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = songs.map((song) => {
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'albumArt': song.albumArt,
        'url': song.url,
        'duration': song.duration.inMilliseconds,
      }).toList();
      
      await prefs.setString(_cacheKeyRecommendSongs, json.encode(jsonList));
      await _saveCacheTime(_cacheKeyRecommendSongs);
      print('已缓存推荐歌曲: ${songs.length}首');
    } catch (e) {
      print('缓存推荐歌曲失败: $e');
    }
  }
  
  /// 获取缓存的推荐歌曲
  static Future<List<Song>?> getCachedRecommendSongs() async {
    try {
      if (!await _isCacheValid(_cacheKeyRecommendSongs)) {
        print('推荐歌曲缓存已过期');
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKeyRecommendSongs);
      
      if (jsonStr == null) return null;
      
      final List jsonList = json.decode(jsonStr);
      final songs = jsonList.map((item) => Song(
        id: item['id'],
        title: item['title'],
        artist: item['artist'],
        album: item['album'],
        albumArt: item['albumArt'] ?? '',
        url: item['url'] ?? '',
        duration: Duration(milliseconds: item['duration'] ?? 0),
        releaseDate: DateTime.now(),
      )).toList();
      
      print('从缓存加载推荐歌曲: ${songs.length}首');
      return songs;
    } catch (e) {
      print('获取缓存推荐歌曲失败: $e');
      return null;
    }
  }
  
  /// 缓存推荐歌单
  static Future<void> cacheRecommendPlaylists(List<Map<String, dynamic>> playlists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyRecommendPlaylists, json.encode(playlists));
      await _saveCacheTime(_cacheKeyRecommendPlaylists);
      print('已缓存推荐歌单: ${playlists.length}个');
    } catch (e) {
      print('缓存推荐歌单失败: $e');
    }
  }
  
  /// 获取缓存的推荐歌单
  static Future<List<Map<String, dynamic>>?> getCachedRecommendPlaylists() async {
    try {
      if (!await _isCacheValid(_cacheKeyRecommendPlaylists)) {
        print('推荐歌单缓存已过期');
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKeyRecommendPlaylists);
      
      if (jsonStr == null) return null;
      
      final List jsonList = json.decode(jsonStr);
      final playlists = jsonList.cast<Map<String, dynamic>>().map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'coverImgUrl': item['coverImgUrl'],
          'playCount': item['playCount'],
        };
      }).toList();
      
      print('从缓存加载推荐歌单: ${playlists.length}个');
      return playlists;
    } catch (e) {
      print('获取缓存推荐歌单失败: $e');
      return null;
    }
  }
  
  /// 缓存搜索结果
  static Future<void> cacheSearchResults(String keyword, List<Song> songs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeySearchPrefix${keyword.toLowerCase()}';
      
      final jsonList = songs.map((song) => {
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'albumArt': song.albumArt,
        'url': song.url,
        'duration': song.duration.inMilliseconds,
      }).toList();
      
      await prefs.setString(cacheKey, json.encode(jsonList));
      await _saveCacheTime(cacheKey);
      print('已缓存搜索结果 "$keyword": ${songs.length}首');
    } catch (e) {
      print('缓存搜索结果失败: $e');
    }
  }
  
  /// 获取缓存的搜索结果
  static Future<List<Song>?> getCachedSearchResults(String keyword) async {
    try {
      final cacheKey = '$_cacheKeySearchPrefix${keyword.toLowerCase()}';
      
      if (!await _isCacheValid(cacheKey)) {
        print('搜索结果缓存已过期: $keyword');
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(cacheKey);
      
      if (jsonStr == null) return null;
      
      final List jsonList = json.decode(jsonStr);
      final songs = jsonList.map((item) => Song(
        id: item['id'],
        title: item['title'],
        artist: item['artist'],
        album: item['album'],
        albumArt: item['albumArt'] ?? '',
        url: item['url'] ?? '',
        duration: Duration(milliseconds: item['duration'] ?? 0),
        releaseDate: DateTime.now(),
      )).toList();
      
      print('从缓存加载搜索结果 "$keyword": ${songs.length}首');
      return songs;
    } catch (e) {
      print('获取缓存搜索结果失败: $e');
      return null;
    }
  }
  
  /// 缓存歌曲播放URL
  static Future<void> cacheSongUrl(String songId, String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'song_url_$songId';
      await prefs.setString(cacheKey, url);
      await _saveCacheTime(cacheKey);
      print('已缓存歌曲URL: $songId');
    } catch (e) {
      print('缓存歌曲URL失败: $e');
    }
  }
  
  /// 获取缓存的歌曲URL
  static Future<String?> getCachedSongUrl(String songId) async {
    try {
      final cacheKey = 'song_url_$songId';
      
      if (!await _isCacheValid(cacheKey)) {
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(cacheKey);
      
      if (url != null) {
        print('从缓存加载歌曲URL: $songId');
      }
      return url;
    } catch (e) {
      print('获取缓存歌曲URL失败: $e');
      return null;
    }
  }
  
  /// 清除所有缓存
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await prefs.remove(key);
        }
      }
      
      print('已清除所有缓存');
    } catch (e) {
      print('清除缓存失败: $e');
    }
  }
  
  /// 获取缓存统计信息
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int cacheCount = 0;
      int totalSize = 0;
      
      for (final key in keys) {
        if (key.startsWith('cache_') && !key.startsWith('cache_time_')) {
          cacheCount++;
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return {
        'count': cacheCount,
        'size': totalSize,
        'sizeKB': (totalSize / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      print('获取缓存统计失败: $e');
      return {'count': 0, 'size': 0, 'sizeKB': '0'};
    }
  }
}
