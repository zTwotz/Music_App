import 'package:flutter/foundation.dart';

import '../../core/services/song_service.dart';
import '../../core/services/artist_service.dart';
import '../../shared/models/song.dart';
import '../../shared/models/artist.dart';

class SongCatalogProvider extends ChangeNotifier {
  final SongService songService;

  SongCatalogProvider({
    required this.songService,
  });

  bool _isLoading = false;
  String? _error;
  List<Song> _cloudSongs = [];
  List<Artist> _artists = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Song> get cloudSongs => _cloudSongs;
  List<Song> get allSongs => _cloudSongs;
  List<Artist> get artists => _artists;

  Future<void> loadSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final songsFuture = songService.fetchCloudSongs();
      final artistsFuture = ArtistService().getAllArtists();

      final results = await Future.wait<dynamic>([songsFuture, artistsFuture]);
      _cloudSongs = results[0] as List<Song>;
      _artists = results[1] as List<Artist>;
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