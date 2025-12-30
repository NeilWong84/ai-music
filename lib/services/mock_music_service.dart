import '../models/song.dart';

/// 模拟音乐服务 - 用于离线模式或网络失败时的备用方案
class MockMusicService {
  /// 获取模拟推荐歌曲
  static List<Song> getMockRecommendSongs() {
    return [
      Song(
        id: 'mock_1',
        title: '晴天',
        artist: '周杰伦',
        album: '叶惠美',
        albumArt: 'https://picsum.photos/seed/song1/300/300',
        url: '', // 模拟数据无实际播放URL
        duration: const Duration(minutes: 4, seconds: 29),
        releaseDate: DateTime(2003, 7, 31),
      ),
      Song(
        id: 'mock_2',
        title: '七里香',
        artist: '周杰伦',
        album: '七里香',
        albumArt: 'https://picsum.photos/seed/song2/300/300',
        url: '',
        duration: const Duration(minutes: 5, seconds: 5),
        releaseDate: DateTime(2004, 8, 3),
      ),
      Song(
        id: 'mock_3',
        title: '稻香',
        artist: '周杰伦',
        album: '魔杰座',
        albumArt: 'https://picsum.photos/seed/song3/300/300',
        url: '',
        duration: const Duration(minutes: 3, seconds: 43),
        releaseDate: DateTime(2008, 10, 15),
      ),
      Song(
        id: 'mock_4',
        title: '告白气球',
        artist: '周杰伦',
        album: '周杰伦的床边故事',
        albumArt: 'https://picsum.photos/seed/song4/300/300',
        url: '',
        duration: const Duration(minutes: 3, seconds: 35),
        releaseDate: DateTime(2016, 6, 24),
      ),
      Song(
        id: 'mock_5',
        title: '夜曲',
        artist: '周杰伦',
        album: '11月的萧邦',
        albumArt: 'https://picsum.photos/seed/song5/300/300',
        url: '',
        duration: const Duration(minutes: 3, seconds: 46),
        releaseDate: DateTime(2005, 11, 1),
      ),
      Song(
        id: 'mock_6',
        title: '演员',
        artist: '薛之谦',
        album: '绅士',
        albumArt: 'https://picsum.photos/seed/song6/300/300',
        url: '',
        duration: const Duration(minutes: 4, seconds: 20),
        releaseDate: DateTime(2015, 5, 20),
      ),
      Song(
        id: 'mock_7',
        title: '成都',
        artist: '赵雷',
        album: '无法长大',
        albumArt: 'https://picsum.photos/seed/song7/300/300',
        url: '',
        duration: const Duration(minutes: 5, seconds: 28),
        releaseDate: DateTime(2017, 2, 21),
      ),
      Song(
        id: 'mock_8',
        title: '大鱼',
        artist: '周深',
        album: '大鱼',
        albumArt: 'https://picsum.photos/seed/song8/300/300',
        url: '',
        duration: const Duration(minutes: 4, seconds: 14),
        releaseDate: DateTime(2016, 5, 20),
      ),
      Song(
        id: 'mock_9',
        title: '起风了',
        artist: '买辣椒也用券',
        album: '起风了',
        albumArt: 'https://picsum.photos/seed/song9/300/300',
        url: '',
        duration: const Duration(minutes: 5, seconds: 15),
        releaseDate: DateTime(2017, 2, 28),
      ),
      Song(
        id: 'mock_10',
        title: '年轮',
        artist: '张碧晨',
        album: '年轮',
        albumArt: 'https://picsum.photos/seed/song10/300/300',
        url: '',
        duration: const Duration(minutes: 4, seconds: 48),
        releaseDate: DateTime(2014, 10, 17),
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
