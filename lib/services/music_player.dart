import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song.dart';

class MusicPlayer extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 播放列表
  List<Song> _playlist = [];
  int _currentIndex = -1;
  
  // 播放状态
  PlayStatus _playStatus = PlayStatus.stopped;
  PlayMode _playMode = PlayMode.sequential;
  
  // 播放进度
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  // 音量
  double _volume = 1.0;
  
  // 当前播放的歌曲
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _playlist.length 
      ? _playlist[_currentIndex] 
      : null;
  
  PlayStatus get playStatus => _playStatus;
  PlayMode get playMode => _playMode;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  
  // 流控制器
  final BehaviorSubject<Duration> _positionSubject = BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<Duration> _durationSubject = BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<PlayStatus> _playStatusSubject = BehaviorSubject.seeded(PlayStatus.stopped);
  final BehaviorSubject<Song?> _currentSongSubject = BehaviorSubject.seeded(null);
  
  // 流
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<PlayStatus> get playStatusStream => _playStatusSubject.stream;
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;

  MusicPlayer() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // 监听播放状态变化
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _playStatus = PlayStatus.playing;
      } else {
        _playStatus = PlayStatus.paused;
      }
      _playStatusSubject.add(_playStatus);
      notifyListeners();
    });

    // 监听位置变化
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      _positionSubject.add(position);
      notifyListeners();
    });

    // 监听缓冲位置变化
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      _duration = bufferedPosition;
      _durationSubject.add(bufferedPosition);
      notifyListeners();
    });

    // 监听播放完成事件
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackCompleted();
      }
    });
  }

  // 设置播放列表
  Future<void> setPlaylist(List<Song> playlist, {int initialIndex = 0}) async {
    _playlist = playlist;
    if (playlist.isNotEmpty && initialIndex < playlist.length) {
      await _loadSong(initialIndex);
    }
  }

  // 添加歌曲到播放列表
  void addSongToPlaylist(Song song) {
    _playlist.add(song);
    notifyListeners();
  }

  // 移除播放列表中的歌曲
  void removeSongFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      
      // 如果移除的是当前播放的歌曲
      if (_currentIndex == index) {
        if (_playlist.isEmpty) {
          _currentIndex = -1;
          _audioPlayer.stop();
        } else if (_currentIndex >= _playlist.length) {
          _currentIndex = _playlist.length - 1;
          _loadSong(_currentIndex);
        } else {
          _loadSong(_currentIndex);
        }
      } else if (index < _currentIndex) {
        _currentIndex--;
      }
      
      notifyListeners();
    }
  }

  // 加载歌曲
  Future<void> _loadSong(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      final song = _playlist[index];
      
      try {
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.url)));
        _currentSongSubject.add(song);
        notifyListeners();
      } catch (e) {
        print('加载歌曲失败: $e');
      }
    }
  }

  // 播放
  Future<void> play() async {
    if (_playlist.isNotEmpty && _currentIndex >= 0) {
      await _audioPlayer.play();
    }
  }

  // 暂停
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // 停止
  Future<void> stop() async {
    await _audioPlayer.stop();
    _playStatus = PlayStatus.stopped;
    _playStatusSubject.add(_playStatus);
    notifyListeners();
  }

  // 播放指定索引的歌曲
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _loadSong(index);
      await play();
    }
  }

  // 播放下一首
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    
    switch (_playMode) {
      case PlayMode.sequential:
        if (_currentIndex < _playlist.length - 1) {
          await playAtIndex(_currentIndex + 1);
        } else {
          // 播放完毕，停止播放
          await stop();
        }
        break;
      case PlayMode.loop:
        if (_currentIndex < _playlist.length - 1) {
          await playAtIndex(_currentIndex + 1);
        } else {
          await playAtIndex(0); // 从头开始循环
        }
        break;
      case PlayMode.shuffle:
        // 随机播放
        if (_playlist.length > 1) {
          int nextIndex;
          do {
            nextIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length).toInt();
          } while (nextIndex == _currentIndex && _playlist.length > 1);
          await playAtIndex(nextIndex);
        }
        break;
    }
  }

  // 播放上一首
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    
    if (_currentIndex > 0) {
      await playAtIndex(_currentIndex - 1);
    } else if (_playMode == PlayMode.loop) {
      await playAtIndex(_playlist.length - 1); // 循环到最后一首
    }
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // 设置播放模式
  void setPlayMode(PlayMode mode) {
    _playMode = mode;
    notifyListeners();
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    notifyListeners();
  }

  // 播放完成回调
  void _onPlaybackCompleted() {
    playNext(); // 自动播放下一首
  }

  // 获取播放进度百分比
  double getProgressPercentage() {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // 获取播放进度文本
  String getProgressText() {
    return '${_formatDuration(_position)} / ${_formatDuration(_duration)}';
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionSubject.close();
    _durationSubject.close();
    _playStatusSubject.close();
    _currentSongSubject.close();
    super.dispose();
  }
}