import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'mock_music_service.dart';
import 'cache_service.dart';
import '../utils/logger.dart';

/// 音乐API服务 - 使用多个免费开源音乐平台
class MusicApiService {
  // Jamendo API 配置
  static const String _jamendoClientId = '56d30c95';
  static const String _jamendoBaseUrl = 'https://api.jamendo.com/v3.0';
  
  // Free Music Archive (FMA) 配置
  static const String _fmaApiKey = 'YOUR_FMA_API_KEY'; // 需要注册获取
  static const String _fmaBaseUrl = 'https://freemusicarchive.org/api';
  
  // Incompetech (Kevin MacLeod) 音乐库
  // 注意：Incompetech 没有公开API，我们使用预定义的歌曲列表
  
  // 请求超时设置
  static const Duration _timeout = Duration(seconds: 10);
  
  /// 带超时的HTTP请求
  Future<http.Response?> _requestWithTimeout(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        return response;
      } else {
        AppLogger.w('请求失败，状态码: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      AppLogger.w('请求超时: $e');
    } catch (e) {
      AppLogger.e('请求异常: $e');
    }
    return null;
  }

  /// 获取推荐歌曲（使用多个开源平台）
  Future<List<Song>> getRecommendSongs({int limit = 30}) async {
    // 1. 先尝试从缓存加载
    final cachedSongs = await CacheService.getCachedRecommendSongs();
    if (cachedSongs != null && cachedSongs.isNotEmpty) {
      print('✅ 使用缓存的推荐歌曲');
      return cachedSongs;
    }

    print('🎵 正在从多个开源平台获取音乐...');
    
    // 2. 使用混合平台获取音乐（Jamendo + Incompetech）
    final mixedSongs = await getMixedPlatformTracks(limit: limit);
    if (mixedSongs.isNotEmpty) {
      print('✅ 成功从多个平台获取 ${mixedSongs.length} 首歌曲');
      await CacheService.cacheRecommendSongs(mixedSongs);
      return mixedSongs;
    }
    
    // 3. 所有平台失败，使用本地模拟数据（包含真实可播放URL）
    print('💾 使用本地模拟数据（Bensound 免费音乐）');
    return MockMusicService.getMockRecommendSongs();
  }

  /// 获取热门歌曲（使用 Jamendo 流行音乐）
  Future<List<Song>> getTopSongs({int limit = 50}) async {
    try {
      print('🎵 获取 Jamendo 热门音乐...');
      // 获取 Jamendo 流行音乐（按播放次数排序）
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&limit=$limit&order=popularity_total&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'].toString(),
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
      print('获取热门歌曲失败: $e');
    }
    
    // 失败时返回本地数据
    return MockMusicService.getMockRecommendSongs();
  }

  /// 搜索歌曲（使用 Jamendo）
  Future<List<Song>> searchSongs(String keyword, {int limit = 30}) async {
    if (keyword.trim().isEmpty) {
      return [];
    }
    
    // 1. 先尝试从缓存加载
    final cachedResults = await CacheService.getCachedSearchResults(keyword);
    if (cachedResults != null && cachedResults.isNotEmpty) {
      print('✅ 使用缓存的搜索结果: $keyword');
      return cachedResults;
    }
    
    // 2. 使用 Jamendo 搜索
    try {
      print('🔍 在 Jamendo 搜索: $keyword');
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&limit=$limit&search=${Uri.encodeComponent(keyword)}&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        final songs = results.map((track) {
          return Song(
            id: track['id'].toString(),
            title: track['name'] ?? '未知歌曲',
            artist: track['artist_name'] ?? '未知歌手',
            album: track['album_name'] ?? '未知专辑',
            albumArt: track['album_image'] ?? track['image'] ?? '',
            url: track['audio'] ?? track['audiodownload'] ?? '',
            duration: Duration(seconds: track['duration'] ?? 0),
            releaseDate: DateTime.now(),
          );
        }).toList();
        
        // 缓存成功的搜索结果
        if (songs.isNotEmpty) {
          print('✅ 搜索到 ${songs.length} 首歌曲');
          await CacheService.cacheSearchResults(keyword, songs);
        }
        
        return songs;
      }
    } catch (e) {
      print('搜索歌曲失败: $e');
    }
    
    // 3. 网络失败，尝试从模拟数据搜索
    print('📡 使用离线数据搜索');
    return MockMusicService.searchMockSongs(keyword);
  }

  /// 获取歌曲播放URL（Jamendo 歌曲已包含URL，此方法用于兼容）
  Future<String?> getSongUrl(String songId) async {
    // Jamendo 的歌曲在获取时已经包含了播放URL
    // 这个方法主要用于保持接口兼容性
    
    // 1. 先尝试从缓存加载
    final cachedUrl = await CacheService.getCachedSongUrl(songId);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      print('✅ 使用缓存的歌曲URL: $songId');
      return cachedUrl;
    }
    
    // 2. 尝试通过 ID 获取歌曲详情
    try {
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&id=$songId&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        if (results.isNotEmpty) {
          final track = results[0];
          final playUrl = track['audio'] ?? track['audiodownload'] ?? '';
          
          // 缓存播放URL
          if (playUrl.isNotEmpty) {
            await CacheService.cacheSongUrl(songId, playUrl);
            return playUrl;
          }
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
      print('🎵 获取歌曲详情: $songId');
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&id=$songId&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        if (results.isEmpty) return null;
        
        final track = results[0];
        
        return Song(
          id: track['id'].toString(),
          title: track['name'] ?? '未知歌曲',
          artist: track['artist_name'] ?? '未知歌手',
          album: track['album_name'] ?? '未知专辑',
          albumArt: track['album_image'] ?? track['image'] ?? '',
          url: track['audio'] ?? track['audiodownload'] ?? '',
          duration: Duration(seconds: track['duration'] ?? 0),
          releaseDate: DateTime.now(),
        );
      }
    } catch (e) {
      print('获取歌曲详情失败: $e');
    }
    return null;
  }

  /// 获取歌单详情（Jamendo 使用播放列表）
  Future<List<Song>> getPlaylistDetail(String playlistId) async {
    try {
      print('🎵 获取播放列表: $playlistId');
      final url = '$_jamendoBaseUrl/playlists/tracks/?client_id=$_jamendoClientId&format=json&id=$playlistId&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'].toString(),
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
      print('获取歌单详情失败: $e');
    }
    return [];
  }

  /// 获取推荐歌单（使用 Jamendo 播放列表）
  Future<List<Map<String, dynamic>>> getRecommendPlaylists({int limit = 10}) async {
    // 1. 先尝试从缓存加载
    final cachedPlaylists = await CacheService.getCachedRecommendPlaylists();
    if (cachedPlaylists != null && cachedPlaylists.isNotEmpty) {
      print('✅ 使用缓存的推荐歌单');
      return cachedPlaylists;
    }
    
    // 2. 获取 Jamendo 播放列表
    try {
      print('🎵 获取 Jamendo 推荐歌单...');
      final url = '$_jamendoBaseUrl/playlists/?client_id=$_jamendoClientId&format=json&limit=$limit&order=popularity_total';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        final playlists = results.map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'] ?? '未知歌单',
            'coverImgUrl': 'https://picsum.photos/seed/${item['id']}/300/300',
            'playCount': 0,
          };
        }).toList();
        
        // 缓存成功的结果
        if (playlists.isNotEmpty) {
          print('✅ 获取 ${playlists.length} 个推荐歌单');
          await CacheService.cacheRecommendPlaylists(playlists);
        }
        
        return playlists;
      }
    } catch (e) {
      print('获取推荐歌单失败: $e');
    }
    
    // 3. 网络请求失败，返回模拟数据
    print('📡 使用离线模拟歌单');
    return MockMusicService.getMockPlaylists();
  }

  /// 获取 Jamendo 音乐（核心方法）
  Future<List<Song>> getJamendoTracks({int limit = 30}) async {
    try {
      // Jamendo 免费音乐API - 无需API key的公开接口
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&limit=$limit&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'].toString(),
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

  /// 根据流派获取音乐
  Future<List<Song>> getTracksByGenre(String genre, {int limit = 30}) async {
    try {
      print('🎵 获取 $genre 音乐...');
      final url = '$_jamendoBaseUrl/tracks/?client_id=$_jamendoClientId&format=json&limit=$limit&tags=$genre&include=musicinfo&audiodownload=mp31';
      final response = await _requestWithTimeout(url);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((track) {
          return Song(
            id: track['id'].toString(),
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
      print('获取流派音乐失败: $e');
    }
    return [];
  }

  /// 获取 Incompetech (Kevin MacLeod) 免费背景音乐
  /// Kevin MacLeod 是著名的免费音乐作曲家
  Future<List<Song>> getIncompetechTracks({int limit = 30}) async {
    try {
      print('🎵 获取 Incompetech 免费背景音乐...');
      
      // Incompetech 没有公开API，这里提供一些热门歌曲的直链
      final incompetechSongs = [
        Song(
          id: 'incompetech_1',
          title: 'Wallpaper',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech1/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Wallpaper.mp3',
          duration: const Duration(minutes: 3, seconds: 22),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_2',
          title: 'Carefree',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech2/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3',
          duration: const Duration(minutes: 1, seconds: 16),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_3',
          title: 'Cipher',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech3/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Cipher.mp3',
          duration: const Duration(minutes: 2, seconds: 17),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_4',
          title: 'Fluffing a Duck',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech4/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Fluffing%20a%20Duck.mp3',
          duration: const Duration(minutes: 1, seconds: 47),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_5',
          title: 'Monkeys Spinning Monkeys',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech5/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Monkeys%20Spinning%20Monkeys.mp3',
          duration: const Duration(minutes: 1, seconds: 49),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_6',
          title: 'Sneaky Snitch',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech6/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sneaky%20Snitch.mp3',
          duration: const Duration(minutes: 1, seconds: 56),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_7',
          title: 'Breaktime - Silent Film Light',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech7/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Breaktime%20-%20Silent%20Film%20Light.mp3',
          duration: const Duration(minutes: 1, seconds: 42),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_8',
          title: 'Pamgaea',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech8/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Pamgaea.mp3',
          duration: const Duration(minutes: 3, seconds: 8),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_9',
          title: 'Take a Chance',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech9/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Take%20a%20Chance.mp3',
          duration: const Duration(minutes: 2, seconds: 55),
          releaseDate: DateTime(2010, 1, 1),
        ),
        Song(
          id: 'incompetech_10',
          title: 'Ultralounge',
          artist: 'Kevin MacLeod',
          album: 'Incompetech Music',
          albumArt: 'https://picsum.photos/seed/incompetech10/300/300',
          url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Ultralounge.mp3',
          duration: const Duration(minutes: 3, seconds: 5),
          releaseDate: DateTime(2010, 1, 1),
        ),
      ];
      
      print('✅ 成功加载 ${incompetechSongs.length} 首 Kevin MacLeod 歌曲');
      return incompetechSongs.take(limit).toList();
    } catch (e) {
      print('获取 Incompetech 音乐失败: $e');
    }
    return [];
  }

  /// 获取所有平台的混合音乐
  Future<List<Song>> getMixedPlatformTracks({int limit = 50}) async {
    print('🎵 从多个平台获取音乐...');
    
    List<Song> allSongs = [];
    
    // 1. 从 Jamendo 获取
    try {
      final jamendoSongs = await getJamendoTracks(limit: 20);
      if (jamendoSongs.isNotEmpty) {
        print('✅ Jamendo: ${jamendoSongs.length} 首');
        allSongs.addAll(jamendoSongs);
      }
    } catch (e) {
      print('⚠️ Jamendo 请求失败: $e');
    }
    
    // 2. 从 Incompetech 获取
    try {
      final incompetechSongs = await getIncompetechTracks(limit: 10);
      if (incompetechSongs.isNotEmpty) {
        print('✅ Incompetech: ${incompetechSongs.length} 首');
        allSongs.addAll(incompetechSongs);
      }
    } catch (e) {
      print('⚠️ Incompetech 加载失败: $e');
    }
    
    // 3. 如果所有平台都失败，使用 Bensound 本地数据
    if (allSongs.isEmpty) {
      print('💾 使用 Bensound 本地数据');
      allSongs = MockMusicService.getMockRecommendSongs();
    }
    
    // 4. 打乱顺序，提供多样化体验
    allSongs.shuffle();
    
    print('✅ 总计获取 ${allSongs.length} 首歌曲');
    return allSongs.take(limit).toList();
  }

  /// 根据平台获取音乐
  Future<List<Song>> getTracksByPlatform(String platform, {int limit = 30}) async {
    switch (platform.toLowerCase()) {
      case 'jamendo':
        return await getJamendoTracks(limit: limit);
      case 'incompetech':
      case 'kevin macleod':
        return await getIncompetechTracks(limit: limit);
      case 'bensound':
        return MockMusicService.getMockRecommendSongs();
      case 'mixed':
      case 'all':
        return await getMixedPlatformTracks(limit: limit);
      default:
        print('⚠️ 未知平台: $platform，使用 Jamendo');
        return await getJamendoTracks(limit: limit);
    }
  }
}
