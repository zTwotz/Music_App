import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../shared/models/song.dart';

class PodcastService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Podcast>> fetchCloudPodcasts() async {
    final response = await _client
        .from('podcasts')
        .select('*, podcast_channels(name, avatar_url)')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final rows = (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return rows.map((item) {
      final channel = item['podcast_channels'] as Map<String, dynamic>?;
      return Podcast.cloud(
        id: item['id'].toString(),
        title: (item['title'] ?? '') as String,
        artist: (channel?['name'] ?? '') as String,
        avatar: channel?['avatar_url'] as String?,
        audioUrl: (item['audio_url'] ?? '') as String,
        coverUrl: item['cover_url'] as String?,
        lyricsUrl: item['lyrics_url'] as String?,
        color: Colors.deepOrange,
      );
    }).where((podcast) => (podcast.audioUrl ?? '').isNotEmpty).toList();
  }
}
