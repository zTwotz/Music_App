import 'package:flutter/foundation.dart';
import '../../core/services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService homeService;

  HomeProvider({required this.homeService});

  List<Map<String, dynamic>> _inspirationItems = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get inspirationItems => _inspirationItems;
  bool get isLoading => _isLoading;

  Future<void> fetchInspiration() async {
    _isLoading = true;
    notifyListeners();

    _inspirationItems = await homeService.fetchInspirationItems();

    _isLoading = false;
    notifyListeners();
  }
}
