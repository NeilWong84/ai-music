import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class PlaylistService {
  static const String _playHistoryKey = 'play_history';
  static const String _favoriteSongsKey = 'favorite_songs';
  static const String _playlistsKey = 'playlists';

  // 播放历史
  Future<void> addPlayHistory(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getPlayHistory();
    
    // 移除重复项
    history.removeWhere((item) => item.id == song.id);
    
    // 添加到开头
    history.insert(0, song);
    
    // 限制历史记录数量
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    await prefs.setStringList(_playHistoryKey, 
        history.map((song) => jsonEncode(song.toJson())).toList());
  }

  Future<List<Song>> getPlayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_playHistoryKey) ?? [];
    
    return historyJson.map((json) => Song.fromJson(jsonDecode(json))).toList();
  }

  // 收藏歌曲
  Future<void> toggleFavorite(Song song) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteSongs();
    final isFavorite = favorites.any((s) => s.id == song.id);
    
    if (isFavorite) {
      // 移除收藏
      favorites.removeWhere((s) => s.id == song.id);
    } else {
      // 添加收藏
      favorites.add(song);
    }
    
    await prefs.setStringList(_favoriteSongsKey, 
        favorites.map((song) => jsonEncode(song.toJson())).toList());
  }

  Future<List<Song>> getFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteSongsKey) ?? [];
    
    return favoritesJson.map((json) => Song.fromJson(jsonDecode(json))).toList();
  }

  Future<bool> isFavorite(String songId) async {
    final favorites = await getFavoriteSongs();
    return favorites.any((song) => song.id == songId);
  }

  // 自定义播放列表
  Future<void> createPlaylist(String name) async {
    final playlists = await getAllPlaylists();
    if (!playlists.containsKey(name)) {
      playlists[name] = [];
      await _savePlaylists(playlists);
    }
  }

  Future<void> addSongToPlaylist(String playlistName, Song song) async {
    final playlists = await getAllPlaylists();
    if (playlists.containsKey(playlistName)) {
      final playlist = playlists[playlistName]!;
      if (!playlist.any((s) => s.id == song.id)) {
        playlist.add(song);
        await _savePlaylists(playlists);
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistName, String songId) async {
    final playlists = await getAllPlaylists();
    if (playlists.containsKey(playlistName)) {
      final playlist = playlists[playlistName]!;
      playlist.removeWhere((s) => s.id == songId);
      await _savePlaylists(playlists);
    }
  }

  Future<void> deletePlaylist(String playlistName) async {
    final playlists = await getAllPlaylists();
    playlists.remove(playlistName);
    await _savePlaylists(playlists);
  }

  Future<Map<String, List<Song>>> getAllPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getStringList(_playlistsKey) ?? [];
    
    Map<String, List<Song>> playlists = {};
    
    for (final item in playlistsJson) {
      final data = jsonDecode(item);
      final name = data['name'];
      final songsJson = data['songs'] as List;
      final songs = songsJson.map((json) => Song.fromJson(jsonDecode(json))).toList();
      playlists[name] = songs;
    }
    
    return playlists;
  }

  Future<List<Song>> getSongsFromPlaylist(String playlistName) async {
    final playlists = await getAllPlaylists();
    return playlists[playlistName] ?? [];
  }

  Future<void> _savePlaylists(Map<String, List<Song>> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists.entries.map((entry) {
      return jsonEncode({
        'name': entry.key,
        'songs': entry.value.map((song) => jsonEncode(song.toJson())).toList(),
      });
    }).toList();
    
    await prefs.setStringList(_playlistsKey, playlistsJson);
  }

  // 搜索功能
  Future<List<Song>> searchSongs(String query) async {
    // 这里应该连接到实际的音乐API
    // 为了演示，我们返回一个模拟结果
    return [];
  }

  // 获取推荐歌曲
  Future<List<Song>> getRecommendations() async {
    // 这里应该连接到实际的推荐API
    // 为了演示，我们返回一个模拟结果
    return [];
  }

  // 获取排行榜歌曲
  Future<List<Song>> getTopCharts() async {
    // 这里应该连接到实际的排行榜API
    // 为了演示，我们返回一个模拟结果
    return [];
  }
}