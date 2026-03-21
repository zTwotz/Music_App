import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/artist.dart';

class ArtistService {
  final _supabase = Supabase.instance.client;

  Future<List<Artist>> searchArtists(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('artists')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (response as List).map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Artist>> getAllArtists() async {
    try {
      final response = await _supabase.from('artists').select().order('name');
      return (response as List).map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
