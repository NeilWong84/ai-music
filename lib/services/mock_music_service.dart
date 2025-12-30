import '../models/song.dart';

/// 模拟音乐服务 - 用于离线模式或网络失败时的备用方案
class MockMusicService {
  /// 获取模拟推荐歌曲（使用真实可播放的音乐URL）
  static List<Song> getMockRecommendSongs() {
    return [
      Song(
        id: 'mock_1',
        title: 'Acoustic Breeze',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song1/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-acousticbreeze.mp3',
        duration: const Duration(minutes: 2, seconds: 37),
        releaseDate: DateTime(2020, 1, 1),
      ),
      Song(
        id: 'mock_2',
        title: 'Sunny',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song2/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-sunny.mp3',
        duration: const Duration(minutes: 2, seconds: 20),
        releaseDate: DateTime(2020, 2, 1),
      ),
      Song(
        id: 'mock_3',
        title: 'Creative Minds',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song3/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-creativeminds.mp3',
        duration: const Duration(minutes: 2, seconds: 25),
        releaseDate: DateTime(2020, 3, 1),
      ),
      Song(
        id: 'mock_4',
        title: 'Ukulele',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song4/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-ukulele.mp3',
        duration: const Duration(minutes: 2, seconds: 26),
        releaseDate: DateTime(2020, 4, 1),
      ),
      Song(
        id: 'mock_5',
        title: 'Little Idea',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song5/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-littleidea.mp3',
        duration: const Duration(minutes: 2, seconds: 13),
        releaseDate: DateTime(2020, 5, 1),
      ),
      Song(
        id: 'mock_6',
        title: 'Once Again',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song6/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-onceagain.mp3',
        duration: const Duration(minutes: 2, seconds: 19),
        releaseDate: DateTime(2020, 6, 1),
      ),
      Song(
        id: 'mock_7',
        title: 'Happy Rock',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song7/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-happyrock.mp3',
        duration: const Duration(minutes: 1, seconds: 45),
        releaseDate: DateTime(2020, 7, 1),
      ),
      Song(
        id: 'mock_8',
        title: 'Summer',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song8/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-summer.mp3',
        duration: const Duration(minutes: 2, seconds: 16),
        releaseDate: DateTime(2020, 8, 1),
      ),
      Song(
        id: 'mock_9',
        title: 'Tenderness',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song9/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-tenderness.mp3',
        duration: const Duration(minutes: 2, seconds: 3),
        releaseDate: DateTime(2020, 9, 1),
      ),
      Song(
        id: 'mock_10',
        title: 'Funny Song',
        artist: 'Benjamin Tissot',
        album: 'Bensound Collection',
        albumArt: 'https://picsum.photos/seed/song10/300/300',
        url: 'https://www.bensound.com/bensound-music/bensound-funnysong.mp3',
        duration: const Duration(minutes: 3, seconds: 6),
        releaseDate: DateTime(2020, 10, 1),
      ),
    ];
  }

  /// 获取模拟推荐歌单
  static List<Map<String, dynamic>> getMockPlaylists() {
    return [
      {
        'id': 'mock_playlist_1',
        'name': '华语经典流行',
        'coverImgUrl': 'https://picsum.photos/seed/playlist1/300/300',
        'playCount': 128950000,
      },
      {
        'id': 'mock_playlist_2',
        'name': '热歌榜',
        'coverImgUrl': 'https://picsum.photos/seed/playlist2/300/300',
        'playCount': 256780000,
      },
      {
        'id': 'mock_playlist_3',
        'name': '抖音热歌',
        'coverImgUrl': 'https://picsum.photos/seed/playlist3/300/300',
        'playCount': 532100000,
      },
      {
        'id': 'mock_playlist_4',
        'name': '网易原创歌曲榜',
        'coverImgUrl': 'https://picsum.photos/seed/playlist4/300/300',
        'playCount': 45680000,
      },
      {
        'id': 'mock_playlist_5',
        'name': '说唱榜',
        'coverImgUrl': 'https://picsum.photos/seed/playlist5/300/300',
        'playCount': 89320000,
      },
      {
        'id': 'mock_playlist_6',
        'name': '欧美热歌',
        'coverImgUrl': 'https://picsum.photos/seed/playlist6/300/300',
        'playCount': 156200000,
      },
      {
        'id': 'mock_playlist_7',
        'name': '国风音乐',
        'coverImgUrl': 'https://picsum.photos/seed/playlist7/300/300',
        'playCount': 67840000,
      },
      {
        'id': 'mock_playlist_8',
        'name': '电音专区',
        'coverImgUrl': 'https://picsum.photos/seed/playlist8/300/300',
        'playCount': 34560000,
      },
      {
        'id': 'mock_playlist_9',
        'name': '民谣精选',
        'coverImgUrl': 'https://picsum.photos/seed/playlist9/300/300',
        'playCount': 78900000,
      },
      {
        'id': 'mock_playlist_10',
        'name': '夜晚必听',
        'coverImgUrl': 'https://picsum.photos/seed/playlist10/300/300',
        'playCount': 98760000,
      },
    ];
  }

  /// 根据关键词搜索模拟歌曲
  static List<Song> searchMockSongs(String keyword) {
    final allSongs = getMockRecommendSongs();
    final lowerKeyword = keyword.toLowerCase();
    
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerKeyword) ||
             song.artist.toLowerCase().contains(lowerKeyword) ||
             song.album.toLowerCase().contains(lowerKeyword);
    }).toList();
  }
}
