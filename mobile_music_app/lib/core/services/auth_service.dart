import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final metadata = <String, dynamic>{};

    if (displayName != null && displayName.trim().isNotEmpty) {
      metadata['display_name'] = displayName.trim();
    }

    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: metadata.isEmpty ? null : metadata,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}