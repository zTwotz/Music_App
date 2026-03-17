import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/song.dart';

class SongService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Song>> fetchCloudSongs() async {
    final response = await _client
        .from('songs')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List).map((item) {
      return Song.cloud(
        id: item['id'].toString(),
        title: item['title'] as String,
        artist: item['artist'] as String,
        audioUrl: item['audio_url'] as String,
        coverUrl: item['cover_url'] as String?,
        lyricsUrl: item['lyrics_url'] as String?,
        color: Colors.green,
      );
    }).toList();
  }
}