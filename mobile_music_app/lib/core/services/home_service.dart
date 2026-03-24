import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/song.dart';

class HomeService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchInspirationItems() async {
    try {
      // Fetch system playlists
      final playlistResponse = await _client
          .from('playlists')
          .select('id, name, description, cover_url')
          .eq('is_system', true)
          .limit(10);

      // Fetch albums
      final albumResponse = await _client
          .from('albums')
          .select('id, title, description, cover_url')
          .limit(10);

      final List<Map<String, dynamic>> items = [];

      for (var p in playlistResponse) {
        // Fetch songs for this playlist to be used in PlaylistDetailScreen
        final songsResponse = await _client
            .from('playlist_songs')
            .select('songs(*)')
            .eq('playlist_id', p['id']);
        
        final List<Song> songs = (songsResponse as List).map<Song>((s) {
          final item = s['songs'] as Map<String, dynamic>;
          return Song.cloud(
            id: item['id'].toString(),
            title: item['title'] as String,
            artist: item['artist'] as String,
            audioUrl: item['audio_url'] as String,
            coverUrl: item['cover_url'] as String?,
            color: Colors.green,
          );
        }).toList();

        items.add({
          'type': 'playlist',
          'id': p['id'],
          'title': p['name'],
          'image': p['cover_url'],
          'isNetwork': true,
          'songs': songs,
        });
      }

      for (var a in albumResponse) {
        // Fetch songs for this album
        final songsResponse = await _client
            .from('songs')
            .select('*')
            .eq('album_id', a['id']);
        
        final List<Song> songs = (songsResponse as List).map<Song>((item) {
          final map = item as Map<String, dynamic>;
          return Song.cloud(
            id: map['id'].toString(),
            title: map['title'] as String,
            artist: map['artist'] as String,
            audioUrl: map['audio_url'] as String,
            coverUrl: map['cover_url'] as String?,
            color: Colors.green,
          );
        }).toList();

        items.add({
          'type': 'album',
          'id': a['id'],
          'title': a['title'],
          'image': a['cover_url'],
          'isNetwork': true,
          'songs': songs,
        });
      }

      items.shuffle();
      return items.take(6).toList();
    } catch (e) {
      return [];
    }
  }
}
