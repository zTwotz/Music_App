import 'package:flutter/foundation.dart';

import '../../core/services/song_service.dart';
import '../../shared/data/demo_songs.dart';
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

  List<Song> get localSongs => demoSongs;
  List<Song> get cloudSongs => _cloudSongs;
  List<Song> get allSongs => [...demoSongs, ..._cloudSongs];

  Future<void> loadSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cloudSongs = await songService.fetchCloudSongs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}