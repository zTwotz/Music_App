import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/lyric_line.dart';
import '../../shared/models/song.dart';
import '../../shared/data/demo_songs.dart';
import 'dart:math';

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  List<LyricLine> _lyrics = [];

  List<Song> _currentQueue = demoSongs;
  final List<String> _history = [];

  bool _isShuffleActive = false;
  bool _isRepeatActive = false;
  final Set<String> _favoriteSongIds = {};


  final Map<String, List<String>> _playlists = {
    'Nhạc chill đêm': ['song_19', 'song_18', 'song_23'],
    'Top bài hát năm 2025': ['song_26', 'song_11', 'song_15'],
    'V-Pop Hits': ['song_01', 'song_02', 'song_07', 'song_09', 'song_48'],
    'Global Top 50': ['song_10', 'song_20', 'song_21', 'song_32', 'song_33'],
    'Giai điệu lofi': ['song_22', 'song_23', 'song_24', 'song_50'],
    'Rap Việt đỉnh cao': ['song_03', 'song_04', 'song_14', 'song_36', 'song_45'],
    'HIEUTHUHAI Collection': ['song_13', 'song_46'],
    'Sơn Tùng M-TP Hits': ['song_06', 'song_07', 'song_08', 'song_38'],
    'The Weeknd Essentials': ['song_10', 'song_11', 'song_12'],
  };

  AudioPlayerController() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        debugPrint('--- Bài hát kết thúc ---');
        // Đối với LoopMode.one, just_audio sẽ tự lặp lại.
        // Chỉ xử lý chuyển bài nếu KHÔNG ở chế độ lặp lại 1 bài.
        if (!_isRepeatActive) {
          debugPrint('Chế độ: Chuyển tiếp bài hát mới...');
          playNext();
        }
      }
      notifyListeners();
    });


    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
  }


  Song? get currentSong => _currentSong;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;
  bool get hasSong => _currentSong != null;
  List<LyricLine> get lyrics => _lyrics;

  bool get isShuffleActive => _isShuffleActive;
  bool get isRepeatActive => _isRepeatActive;
  bool get isFavorite => _currentSong != null && _favoriteSongIds.contains(_currentSong!.id);
  Set<String> get favoriteSongIds => _favoriteSongIds;
  Map<String, List<String>> get playlists => _playlists;

  double get progress {
    if (_duration.inMilliseconds <= 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  int get currentLyricIndex {
    if (_lyrics.isEmpty) return -1;

    for (int i = _lyrics.length - 1; i >= 0; i--) {
      if (_position >= _lyrics[i].time) {
        return i;
      }
    }
    return -1;
  }

  Future<void> selectSong(Song song, {List<Song>? queue}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (queue != null) {
        _currentQueue = queue;
      }

      final isNewSong = _currentSong?.id != song.id;
      _currentSong = song;

      if (isNewSong) {
        _position = Duration.zero;
        _duration = Duration.zero;
        _lyrics = [];
        await _loadLyrics(song.lyricsAsset);
        await _player.setAsset(song.audioAsset);
        
        // Luôn đảm bảo LoopMode chính xác khi đổi bài
        await _player.setLoopMode(_isRepeatActive ? LoopMode.one : LoopMode.off);
      }

      // Xóa điểm seek cũ và phát ngay để tránh mất tiếng trên Web
      await _player.seek(Duration.zero);
      await _player.play();

    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLyrics(String assetPath) async {
    try {
      // Fix potential web asset path issues (double "assets/" prefix)
      String cleanPath = assetPath;
      if (cleanPath.startsWith('assets/assets/')) {
        cleanPath = cleanPath.replaceFirst('assets/', '');
      }
      
      final raw = await rootBundle.loadString(cleanPath);
      _lyrics = _parseLrc(raw);
    } catch (e) {
      debugPrint('Lyrics load error: $e for path $assetPath');
      // If primary path fails, try without leading "assets/" as fallback
      if (assetPath.startsWith('assets/')) {
        try {
          final fallbackPath = assetPath.replaceFirst('assets/', '');
          final raw = await rootBundle.loadString(fallbackPath);
          _lyrics = _parseLrc(raw);
          return;
        } catch (_) {}
      }
      _lyrics = [];
    }
  }


  List<LyricLine> _parseLrc(String raw) {
    final lines = raw.split('\n');
    final result = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{1,3}))?\](.*)');

    for (final line in lines) {
      final match = regex.firstMatch(line.trim());
      if (match == null) continue;

      final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
      final millisRaw = match.group(3) ?? '0';
      final text = (match.group(4) ?? '').trim();

      int millis = 0;
      if (millisRaw.isNotEmpty) {
        if (millisRaw.length == 1) {
          millis = int.parse(millisRaw) * 100;
        } else if (millisRaw.length == 2) {
          millis = int.parse(millisRaw) * 10;
        } else {
          millis = int.parse(millisRaw.substring(0, 3));
        }
      }

      result.add(
        LyricLine(
          time: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: millis,
          ),
          text: text.isEmpty ? '...' : text,
        ),
      );
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_currentSong != null) {
          await _player.play();
        }
      }
    } catch (e) {
      debugPrint('Play/Pause error: $e');
    } finally {
      notifyListeners();
    }
  }

  void toggleShuffle() {
    _isShuffleActive = !_isShuffleActive;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeatActive = !_isRepeatActive;
    _player.setLoopMode(_isRepeatActive ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }


  void toggleFavorite() {
    if (_currentSong == null) return;
    toggleFavoriteFor(_currentSong!.id);
  }

  void toggleFavoriteFor(String id) {
    if (_favoriteSongIds.contains(id)) {
      _favoriteSongIds.remove(id);
    } else {
      _favoriteSongIds.add(id);
    }
    notifyListeners();
  }

  void createPlaylist(String name) {
    if (name.isNotEmpty && !_playlists.containsKey(name)) {
      _playlists[name] = [];
      notifyListeners();
    }
  }

  void addSongToPlaylist(String playlistName, String songId) {
    if (_playlists.containsKey(playlistName)) {
      if (!_playlists[playlistName]!.contains(songId)) {
        _playlists[playlistName]!.add(songId);
        notifyListeners();
      }
    }
  }

  Future<void> playPrevious() async {
    // 1. Nếu có lịch sử, quay lại bài hát thực tế đã phát trước đó (đã lưu trong _history)
    if (_history.isNotEmpty) {
      final prevSongId = _history.removeLast();
      debugPrint('Lùi bài: Quay lại bài từ Lịch sử (ID: $prevSongId)');
      try {
        final song = demoSongs.firstWhere((s) => s.id == prevSongId);
        await selectSong(song);
        return;
      } catch (e) {
        debugPrint('Không tìm thấy bài trong lịch sử: $e');
      }
    }

    // 2. Nếu lịch sử trống (hoặc lỗi), quay lại bài trước đó theo thứ tự danh sách (Sequential fallback)
    if (_currentSong == null || _currentQueue.isEmpty) return;
    int currentIndex = _currentQueue.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex == -1) return;

    int prevIndex = currentIndex > 0 ? currentIndex - 1 : _currentQueue.length - 1;
    debugPrint('Lùi bài: Không có lịch sử, lùi tuần tự danh sách (Index $prevIndex)');
    await selectSong(_currentQueue[prevIndex]);
  }

  Future<void> playNext() async {
    if (_currentSong == null || _currentQueue.isEmpty) return;

    // Lưu bài hiện tại vào lịch sử trước khi chuyển sang bài mới
    _history.add(_currentSong!.id);
    // Giảm kích thước lịch sử nếu quá dài (ví dụ tối đa 50 bài)
    if (_history.length > 50) _history.removeAt(0);

    int currentIndex = _currentQueue.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex == -1) return;

    int nextIndex;
    if (_isShuffleActive) {
      if (_currentQueue.length > 1) {
        final random = Random();
        nextIndex = random.nextInt(_currentQueue.length);
        if (nextIndex == currentIndex) {
          nextIndex = (nextIndex + 1) % _currentQueue.length;
        }
      } else {
        nextIndex = currentIndex;
      }
      debugPrint('Chuyển tiếp: Chế độ Ngẫu nhiên -> Index $nextIndex');
    } else {
      nextIndex = currentIndex < _currentQueue.length - 1 ? currentIndex + 1 : 0;
      debugPrint('Chuyển tiếp: Chế độ Tuần tự -> Index $nextIndex');
    }
    
    await selectSong(_currentQueue[nextIndex]);
  }



  Future<void> seek(Duration value) async {
    try {
      await _player.seek(value);
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  String formatTime(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}