import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadAvatar(File file) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final fileExt = file.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'avatars/$fileName';

      await _client.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      
      // Update the profile table
      await _client.from('profiles').upsert({
        'id': user.id,
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAvatarUrl(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      return response?['avatar_url'] as String?;
    } catch (e) {
      return null;
    }
  }
}
