// TODO: 此文件需要重新实现以符合最新的 audio_service API
// 目前使用 music_player.dart 作为音频播放的主要实现

/*
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song.dart';

class AudioPlayerHandler implements AudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final BehaviorSubject<List<MediaItem>> _queue = BehaviorSubject.seeded([]);
  final BehaviorSubject<PlayMode> _playMode = BehaviorSubject.seeded(PlayMode.sequential);
  final BehaviorSubject<int?> _currentIndex = BehaviorSubject.seeded(null);
  final BehaviorSubject<Duration> _position = BehaviorSubject.seeded(Duration.zero);
  final BehaviorSubject<double> _speed = BehaviorSubject.seeded(1.0);

  // 播放列表
  List<Song> _songs = [];
  
  // 当前播放歌曲
  Song? _currentSong;

  @override
  Stream<MediaItem?> get mediaItem => _player.currentIndexStream
      .map((index) => index != null && index < _queue.value.length ? _queue.value[index] : null);

  @override
  Stream<PlaybackState> get playbackState {
    return Rx.combineLatest3(
      _player.playerStateStream,
      _player.positionStream,
      _player.bufferedPositionStream,
      (playerState, position, bufferedPosition) => PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playerState.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.setRating,
          MediaAction.playMediaItem,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[playerState.processingState]!,
        playing: playerState.playing,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  @override
  Stream<List<MediaItem>> get queue => _queue.stream;

  @override
  Stream<double> get speed => _speed.stream;

  @override
  Stream<int?> get currentIndex => _currentIndex.stream;

  @override
  Stream<Duration> get position => _position.stream;

  @override
  Stream<PlayMode> get playMode => _playMode.stream;

  // 播放歌曲
  Future<void> playSong(Song song) async {
    _currentSong = song;
    final mediaItem = MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: Uri.parse(song.albumArt),
    );

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(song.url),
        tag: mediaItem,
      ),
    );
    await _player.play();
  }

  // 播放歌曲列表
  Future<void> playSongs(List<Song> songs, {int initialIndex = 0}) async {
    _songs = songs;
    final mediaItems = songs.map((song) => MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: Uri.parse(song.albumArt),
    )).toList();

    _queue.add(mediaItems);
    final audioSource = ConcatenatingAudioSource(
      children: mediaItems.map((item) => AudioSource.uri(Uri.parse(item.id), tag: item)).toList(),
    );
    
    await _player.setAudioSource(audioSource, initialIndex: initialIndex);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setPlayMode(PlayMode mode) async {
    _playMode.add(mode);
    switch (mode) {
      case PlayMode.sequential:
        _player.setShuffleModeEnabled(false);
        // 设置为不循环
        break;
      case PlayMode.loop:
        _player.setShuffleModeEnabled(false);
        // 设置为单曲循环或列表循环
        break;
      case PlayMode.shuffle:
        _player.setShuffleModeEnabled(true);
        break;
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _speed.add(speed);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // 添加到队列
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    // 在指定位置插入队列项
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    _queue.add(newQueue);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    // 更新媒体项
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    // 从队列移除项目
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // 从队列移除指定索引项目
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seekTo(index);
  }

  @override
  Future<void> prepare() => _player.load();

  @override
  Future<void> prepareFromMediaId(String mediaId) => _player.load();

  @override
  Future<void> prepareFromSearch(String query, [Map<String, dynamic>? extras]) => _player.load();

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) => _player.load();

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    await _player.load();
    await _player.play();
  }

  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) async {
    await _player.load();
    await _player.play();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await _player.load();
    await _player.play();
  }

  @override
  Future<void> setRating(Rating rating) async {
    // 设置评分
  }

  @override
  Future<void> setRatingForMediaItem(String mediaId, Rating rating) async {
    // 为媒体项设置评分
  }

  @override
  Stream<Rating> get rating => _player.currentIndexStream
      .map((index) => Rating.newHeartRating(false));

  @override
  Stream<Map<String, dynamic>> get customActions => const Stream.empty();

  @override
  Stream<dynamic> get androidCustomAction => const Stream.empty();

  @override
  Future<void> sendCustomAction(String action, [Map<String, dynamic>? extras]) async {
    // 发送自定义操作
  }

  @override
  Future<void> fastForward() => _player.seek(_player.position + const Duration(seconds: 15));

  @override
  Future<void> rewind() => _player.seek(_player.position - const Duration(seconds: 15));

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // 设置重复模式
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // 设置随机模式
  }

  @override
  Stream<AudioServiceRepeatMode> get repeatMode => const Stream.empty();

  @override
  Stream<AudioServiceShuffleMode> get shuffleMode => const Stream.empty();

  @override
  Future<void> onTaskRemoved() async {
    // 任务移除时的处理
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setPlayingRoute(PlayingRoute playingRoute) => _player.setDeviceId(playingRoute.deviceId);

  @override
  Stream<PlayingRoute> get playingRoute => _player.playingRouteStream;

  @override
  Future<void> jumpToQueueItem(int index) => skipToQueueItem(index);

  @override
  MediaItem? get mediaItemValue => _player.currentIndex != null && 
      _player.currentIndex! < _queue.value.length 
      ? _queue.value[_player.currentIndex!] 
      : null;

  @override
  int? get currentIndexValue => _player.currentIndex;

  @override
  Duration get positionValue => _player.position;

  @override
  double get speedValue => _player.speed;

  @override
  PlaybackState get playbackStateValue {
    final playerState = _player.playerState;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playerState.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.setRating,
        MediaAction.playMediaItem,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[playerState.processingState]!,
      playing: playerState.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }

  @override
  PlayMode get playModeValue => _playMode.value;

  @override
  void close() {
    _player.dispose();
    _queue.close();
    _playMode.close();
    _currentIndex.close();
    _position.close();
    _speed.close();
  }
}
*/