import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/widgets/mini_player.dart';
import '../player/full_player_screen.dart';

class FavoriteSongsScreen extends StatelessWidget {
  final AudioPlayerController controller;

  const FavoriteSongsScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final favoriteSongs = demoSongs
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
                        child: Image.asset(
                          song.coverAsset,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.white10,
                            child: const Icon(Icons.music_note),
                          ),
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
                          // Allow removing from favorites directly
                          controller.toggleFavoriteFor(song.id);
                        },
                      ),
                      onTap: () {
                        controller.selectSong(song, queue: favoriteSongs);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullPlayerScreen(
                              controller: controller,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
