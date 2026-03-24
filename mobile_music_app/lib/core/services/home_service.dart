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

  Future<List<Map<String, dynamic>>> fetchRecentItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('user_recent_items')
          .select('*')
          .eq('user_id', user.id)
          .order('last_interacted_at', ascending: false)
          .limit(8);

      final List<Map<String, dynamic>> results = [];
      for (var item in response) {
        final type = item['item_type'] as String;
        final key = item['item_key'] as String;

        try {
          Map<String, dynamic>? data;
          switch (type) {
            case 'song':
              data = await _fetchSongById(key);
              break;
            case 'artist':
              data = await _fetchArtistById(key);
              break;
            case 'playlist':
              data = await _fetchPlaylistById(key);
              break;
            case 'album':
              data = await _fetchAlbumById(key);
              break;
            case 'liked_songs':
              data = {
                'type': 'liked_songs',
                'title': 'Bài hát đã thích',
                'image': 'assets/covers_demo/liked_songs.png',
                'isNetwork': false,
              };
              break;
          }

          if (data != null) {
            results.add(data);
          }
        } catch (err) {
          // Skip if individual item fetch fails
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchSongById(String id) async {
    final response = await _client
        .from('songs')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final song = Song.cloud(
      id: response['id'].toString(),
      title: response['title'],
      artist: response['artist'],
      audioUrl: response['audio_url'],
      coverUrl: response['cover_url'],
      color: Colors.green,
    );

    return {
      'type': 'song',
      'id': response['id'],
      'title': response['title'],
      'image': response['cover_url'],
      'isNetwork': true,
      'song_data': song,
    };
  }

  Future<Map<String, dynamic>?> _fetchArtistById(String id) async {
    final response = await _client
        .from('artists')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return {
      'type': 'artist',
      'id': response['id'],
      'title': response['name'],
      'image': response['avatar_url'],
      'isNetwork': true,
    };
  }

  Future<Map<String, dynamic>?> _fetchPlaylistById(String id) async {
    final response = await _client
        .from('playlists')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // Also fetch songs for this playlist
    final songsResponse = await _client
        .from('playlist_songs')
        .select('songs(*)')
        .eq('playlist_id', id);

    final songs = (songsResponse as List).map<Song>((s) {
      final item = s['songs'] as Map<String, dynamic>;
      return Song.cloud(
        id: item['id'].toString(),
        title: item['title'],
        artist: item['artist'],
        audioUrl: item['audio_url'],
        coverUrl: item['cover_url'],
        color: Colors.green,
      );
    }).toList();

    return {
      'type': 'playlist',
      'id': response['id'],
      'title': response['name'],
      'image': response['cover_url'],
      'isNetwork': true,
      'songs': songs,
    };
  }

  Future<Map<String, dynamic>?> _fetchAlbumById(String id) async {
    final response = await _client
        .from('albums')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    // Fetch songs for this album
    final songsResponse = await _client
        .from('songs')
        .select('*')
        .eq('album_id', id);

    final songs = (songsResponse as List).map<Song>((item) {
      return Song.cloud(
        id: item['id'].toString(),
        title: item['title'],
        artist: item['artist'],
        audioUrl: item['audio_url'],
        coverUrl: item['cover_url'],
        color: Colors.green,
      );
    }).toList();

    return {
      'type': 'album',
      'id': response['id'],
      'title': response['title'],
      'image': response['cover_url'],
      'isNetwork': true,
      'songs': songs,
    };
  }
}
