import 'package:flutter/foundation.dart';
import '../../core/services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService homeService;

  HomeProvider({required this.homeService});

  List<Map<String, dynamic>> _inspirationItems = [];
  List<Map<String, dynamic>> _recentItems = [];
  bool _isLoading = false;
  bool _isRecentLoading = false;

  List<Map<String, dynamic>> get inspirationItems => _inspirationItems;
  List<Map<String, dynamic>> get recentItems => _recentItems;
  bool get isLoading => _isLoading;
  bool get isRecentLoading => _isRecentLoading;

  Future<void> fetchInspiration() async {
    _isLoading = true;
    notifyListeners();

    _inspirationItems = await homeService.fetchInspirationItems();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecent() async {
    _isRecentLoading = true;
    notifyListeners();

    _recentItems = await homeService.fetchRecentItems();

    _isRecentLoading = false;
    notifyListeners();
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchInspiration(),
      fetchRecent(),
    ]);
  }
}
