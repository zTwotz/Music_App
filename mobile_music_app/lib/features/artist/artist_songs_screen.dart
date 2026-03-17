import 'package:flutter/material.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../player/full_player_screen.dart';

class ArtistSongsScreen extends StatelessWidget {
  final String artistName;
  final AudioPlayerController controller;
  final List<Song> songs;

  const ArtistSongsScreen({
    super.key,
    required this.artistName,
    required this.controller,
    List<Song>? songs,
  }) : songs = songs ?? demoSongs;

  @override
  Widget build(BuildContext context) {
    List<String> extractArtists(String artistStr) {
      final normalized = artistStr.replaceAll(
        RegExp(
          r'\s+(ft\.?|feat\.?|x|&|-)\s+|,\s*',
          caseSensitive: false,
        ),
        '|||',
      );

      return normalized
          .split('|||')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final targetArtists = extractArtists(artistName);

    final artistSongs = songs.where((s) {
      final sourceArtists = extractArtists(s.artist);
      return targetArtists.any((target) => sourceArtists.contains(target));
    }).toList();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            title: Text('Bài hát của $artistName'),
          ),
          backgroundColor: const Color(0xFF121212),
          body: artistSongs.isEmpty
              ? const Center(
                  child: Text(
                    'Không có bài hát nào',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: artistSongs.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final song = artistSongs[index];
                    final isCurrentSong = controller.currentSong?.id == song.id;

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
                          color: isCurrentSong ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrentSong)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: AnimatedEqualizer(
                                isPlaying: controller.isPlaying,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => showSongOptionsBottomSheet(
                              context,
                              song: song,
                              controller: controller,
                              allSongs: songs,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.selectSong(song, queue: artistSongs);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullPlayerScreen(
                              controller: controller,
                              allSongs: songs,
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