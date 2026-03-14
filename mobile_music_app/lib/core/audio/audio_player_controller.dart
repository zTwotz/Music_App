import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../shared/models/lyric_line.dart';
import '../../shared/models/song.dart';

class AudioPlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  List<LyricLine> _lyrics = [];

  AudioPlayerController() {
    _player.playerStateStream.listen((_) {
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

  Future<void> selectSong(Song song) async {
    try {
      _isLoading = true;
      notifyListeners();

      final isNewSong = _currentSong?.id != song.id;
      _currentSong = song;

      if (isNewSong) {
        _position = Duration.zero;
        _duration = Duration.zero;
        _lyrics = [];
        await _loadLyrics(song.lyricsAsset);
        await _player.setAsset(song.audioAsset);
      }

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
      final raw = await rootBundle.loadString(assetPath);
      _lyrics = _parseLrc(raw);
    } catch (e) {
      debugPrint('Lyrics load error: $e');
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