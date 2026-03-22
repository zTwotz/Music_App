import 'package:flutter/material.dart';

/// Tracks whether [FullPlayerScreen] is the top-most route so the global
/// mini-player overlay can hide itself.
class PlayerRouteObserver extends NavigatorObserver with ChangeNotifier {
  static const String fullPlayerRouteName = '/full-player';

  bool _isFullPlayerOpen = false;
  bool get isFullPlayerOpen => _isFullPlayerOpen;

  bool _isFullPlayer(Route<dynamic>? route) {
    return route?.settings.name == fullPlayerRouteName;
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (_isFullPlayer(route)) {
      _isFullPlayerOpen = true;
      notifyListeners();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (_isFullPlayer(route)) {
      _isFullPlayerOpen = false;
      notifyListeners();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    if (_isFullPlayer(route)) {
      _isFullPlayerOpen = false;
      notifyListeners();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (_isFullPlayer(oldRoute)) {
      _isFullPlayerOpen = false;
      notifyListeners();
    }
    if (_isFullPlayer(newRoute)) {
      _isFullPlayerOpen = true;
      notifyListeners();
    }
  }
}
