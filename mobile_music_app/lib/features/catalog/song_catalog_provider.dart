import 'package:flutter/foundation.dart';

import '../../core/services/song_service.dart';
import '../../core/services/song_service.dart';
import '../../shared/models/song.dart';

class SongCatalogProvider extends ChangeNotifier {
  final SongService songService;

  SongCatalogProvider({
    required this.songService,
  });

  bool _isLoading = false;
  String? _error;
  List<Song> _cloudSongs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Song> get cloudSongs => _cloudSongs;
  List<Song> get allSongs => _cloudSongs;

  Future<void> loadSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cloudSongs = await songService.fetchCloudSongs();
    } catch (e) {
      _error = e.toString();
      debugPrint('Load cloud songs error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSongs() async {
    await loadSongs();
  }
}