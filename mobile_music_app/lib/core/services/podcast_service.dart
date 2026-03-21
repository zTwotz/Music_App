import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../shared/models/song.dart';

class PodcastService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Podcast>> fetchCloudPodcasts() async {
    final response = await _client
        .from('v_podcasts')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final rows = (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return rows.map((item) {
      return Podcast.cloud(
        id: item['id'].toString(),
        title: (item['title'] ?? '') as String,
        artist: (item['channel_name'] ?? '') as String,
        channelId: item['channel_id'].toString(),
        channelName: item['channel_name'] as String?,
        channelAvatarUrl: item['channel_avatar_url'] as String?,
        subscriberCount: (item['subscriber_count'] as num?)?.toInt() ?? 0,
        listenCount: (item['listen_count'] as num?)?.toInt() ?? 0,
        audioUrl: (item['audio_url'] ?? '') as String,
        coverUrl: item['cover_url'] as String?,
        lyricsUrl: item['lyrics_url'] as String?,
        color: Colors.deepOrange,
      );
    }).where((p) => (p.audioUrl ?? '').isNotEmpty).toList();
  }

  Future<void> recordListen(String podcastId) async {
    try {
      await _client.rpc('record_podcast_listen', params: {'p_podcast_id': podcastId});
    } catch (e) {
      debugPrint('Record listen error: $e');
    }
  }

  Future<void> subscribeChannel(String channelId) async {
    await _client.rpc('subscribe_to_channel', params: {'p_channel_id': channelId});
  }

  Future<void> unsubscribeChannel(String channelId) async {
    await _client.rpc('unsubscribe_from_channel', params: {'p_channel_id': channelId});
  }

  Future<bool> isSubscribed(String channelId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final response = await _client
        .from('channel_subscriptions')
        .select('id')
        .eq('user_id', user.id)
        .eq('channel_id', channelId)
        .limit(1);
    
    return (response as List).isNotEmpty;
  }
}
