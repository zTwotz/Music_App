import 'package:flutter/foundation.dart';
import '../../core/services/podcast_service.dart';
import '../../core/services/podcast_service.dart';
import '../../shared/models/song.dart';

class PodcastCatalogProvider extends ChangeNotifier {
  final PodcastService podcastService;

  PodcastCatalogProvider({required this.podcastService});

  bool _isLoading = false;
  String? _error;
  List<Podcast> _cloudPodcasts = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Podcast> get cloudPodcasts => _cloudPodcasts;
  List<Podcast> get allPodcasts => _cloudPodcasts;

  Future<void> loadPodcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cloudPodcasts = await podcastService.fetchCloudPodcasts();
    } catch (e) {
      _error = e.toString();
      debugPrint('Load cloud podcasts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPodcasts() async {
    await loadPodcasts();
  }
}
