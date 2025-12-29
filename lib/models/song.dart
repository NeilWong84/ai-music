class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String albumArt;
  final String url;
  final Duration duration;
  final String genre;
  final DateTime releaseDate;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArt,
    required this.url,
    required this.duration,
    this.genre = '',
    required this.releaseDate,
  });

  // 从JSON创建Song对象
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      albumArt: json['albumArt'] ?? '',
      url: json['url'] ?? '',
      duration: Duration(
        seconds: json['duration'] != null ? json['duration'] : 0,
      ),
      genre: json['genre'] ?? '',
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : DateTime.now(),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'url': url,
      'duration': duration.inSeconds,
      'genre': genre,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }
}

// 播放模式枚举
enum PlayMode { sequential, loop, shuffle }

// 播放状态枚举
enum PlayStatus { stopped, playing, paused }