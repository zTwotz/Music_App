import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider({
    required this.authService,
  });

  StreamSubscription<AuthState>? _authSubscription;

  User? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  String get email => _user?.email ?? '';

  String get displayName {
    final metadataValue = _user?.userMetadata?['display_name'];
    if (metadataValue is String && metadataValue.trim().isNotEmpty) {
      return metadataValue.trim();
    }

    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Người dùng';
  }

  void bootstrap() {
    _user = authService.currentUser;
    _isInitializing = false;
    notifyListeners();

    _authSubscription = authService.authStateChanges.listen(
      (data) {
        _user = data.session?.user;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _mapError(error);
        notifyListeners();
      },
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.signIn(
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = _mapError(error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (response.session == null) {
        return 'Đăng ký thành công. Hãy kiểm tra email để xác nhận tài khoản trước khi đăng nhập.';
      }

      return 'Đăng ký thành công.';
    } catch (error) {
      _errorMessage = _mapError(error);
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.signOut();
    } catch (error) {
      _errorMessage = _mapError(error);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapError(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      if (message.contains('invalid login credentials')) {
        return 'Email hoặc mật khẩu không đúng.';
      }

      if (message.contains('email not confirmed')) {
        return 'Email chưa được xác nhận.';
      }

      if (message.contains('user already registered')) {
        return 'Email này đã được đăng ký.';
      }

      return error.message;
    }

    final text = error.toString().toLowerCase();

    if (text.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không đúng.';
    }

    if (text.contains('email not confirmed')) {
      return 'Email chưa được xác nhận.';
    }

    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}