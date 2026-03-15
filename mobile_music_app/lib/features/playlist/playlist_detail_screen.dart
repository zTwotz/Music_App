import 'package:flutter/material.dart';
import '../../shared/models/song.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../player/full_player_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String title;
  final List<Song> songs;
  final AudioPlayerController controller;

  const PlaylistDetailScreen({
    super.key,
    required this.title,
    required this.songs,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            title: Text(title),
          ),
          backgroundColor: const Color(0xFF121212),
          body: songs.isEmpty
              ? const Center(
                  child: Text(
                    'Không có bài hát nào',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: songs.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isCurrentSong = controller.currentSong?.id == song.id;

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
                              child: AnimatedEqualizer(isPlaying: controller.isPlaying),
                            ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => showSongOptionsBottomSheet(
                              context,
                              song: song,
                              controller: controller,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.selectSong(song, queue: songs);
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
