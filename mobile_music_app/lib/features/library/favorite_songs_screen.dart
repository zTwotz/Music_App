import 'package:flutter/material.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../core/navigation/player_navigator.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/models/song.dart';

class FavoriteSongsScreen extends StatelessWidget {
  final AudioPlayerController controller;
  final List<Song> songs;

  const FavoriteSongsScreen({
    super.key,
    required this.controller,
    List<Song>? songs,
  }) : songs = songs ?? demoSongs;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final favoriteSongs = songs
            .where((song) => controller.favoriteSongIds.contains(song.id))
            .toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            title: const Text('Bài hát đã thích'),
          ),
          backgroundColor: const Color(0xFF121212),
          body: favoriteSongs.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có bài hát yêu thích nào',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteSongs.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final song = favoriteSongs[index];
                    final isPlaying = controller.currentSong?.id == song.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: _buildSongCover(song),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          color: isPlaying ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          controller.toggleFavoriteFor(song.id);
                        },
                      ),
                      onTap: () {
                        controller.selectSong(song, queue: favoriteSongs);
                        pushFullPlayer(
                          context,
                          controller: controller,
                          allSongs: songs,
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildSongCover(Song song) {
    if ((song.coverAsset ?? '').isNotEmpty) {
      return Image.asset(
        song.coverAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white10,
          child: const Icon(Icons.music_note),
        ),
      );
    }

    if ((song.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        song.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white10,
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return Container(
      color: Colors.white10,
      child: const Icon(Icons.music_note),
    );
  }
}