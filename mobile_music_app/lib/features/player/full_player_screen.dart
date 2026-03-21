import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../artist/artist_songs_screen.dart';
import '../podcast/channel_screen.dart';
import 'lyrics_screen.dart';

class FullPlayerScreen extends StatelessWidget {
  final AudioPlayerController controller;
  final List<Song> allSongs;

  const FullPlayerScreen({
    super.key,
    required this.controller,
    List<Song>? allSongs,
  }) : allSongs = allSongs ?? demoSongs;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final song = controller.currentSong;

        if (song == null) {
          return const Scaffold(
            body: Center(
              child: Text('Chưa có bài hát nào được chọn'),
            ),
          );
        }

        final maxSeconds = controller.duration.inSeconds > 0
            ? controller.duration.inSeconds.toDouble()
            : 1.0;

        final currentSeconds = controller.position.inSeconds.clamp(
          0,
          controller.duration.inSeconds > 0 ? controller.duration.inSeconds : 1,
        ).toDouble();

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2C333A),
                  Color(0xFF121212),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                        const Expanded(
                          child: Text(
                            'Đang phát',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () => showSongOptionsBottomSheet(
                            context,
                            song: song,
                            controller: controller,
                            allSongs: allSongs,
                          ),
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildSongCover(song),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _buildArtistLinks(context, song),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: controller.toggleFavorite,
                          icon: Icon(
                            controller.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                controller.isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                      ),
                      child: Slider(
                        value: currentSeconds,
                        min: 0,
                        max: maxSeconds,
                        onChanged: (value) {
                          controller.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(controller.formatTime(controller.position)),
                        Text(controller.formatTime(controller.duration)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: controller.toggleShuffle,
                          icon: Icon(
                            Icons.shuffle,
                            size: 28,
                            color: controller.isShuffleActive
                                ? Colors.green
                                : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.playPrevious,
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            onPressed: controller.togglePlayPause,
                            icon: Icon(
                              controller.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.playNext,
                          icon: const Icon(
                            Icons.skip_next,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.toggleRepeat,
                          icon: Icon(
                            controller.isRepeatActive
                                ? Icons.repeat_one
                                : Icons.repeat,
                            size: 28,
                            color: controller.isRepeatActive
                                ? Colors.green
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _LyricsPreviewCard(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildArtistLinks(BuildContext context, Song song) {
    final artistStr = song.artist;
    final normalized = artistStr.replaceAll(
      RegExp(
        r'\s+(ft\.?|feat\.?|x|&|-)\s+|,\s*',
        caseSensitive: false,
      ),
      '|||',
    );

    final names = normalized.split('|||').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    List<Widget> links = [];
    for (int i = 0; i < names.length; i++) {
      links.add(
        GestureDetector(
          onTap: () {
            if (song is Podcast && song.channelId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelScreen(
                    channelId: song.channelId!,
                    channelName: song.channelName ?? song.artist,
                    avatarUrl: song.channelAvatarUrl,
                    initialSubscribers: song.subscriberCount,
                    controller: controller,
                    allSongs: allSongs,
                  ),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistSongsScreen(
                  artistName: names[i],
                  controller: controller,
                  songs: allSongs,
                ),
              ),
            );
          },
          child: Text(
            names[i],
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white70,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white38,
            ),
          ),
        ),
      );

      if (i < names.length - 1) {
        links.add(
          const Text(
            ' ft. ',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white38,
            ),
          ),
        );
      }
    }
    return links;
  }

  Widget _buildSongCover(Song song) {
    if ((song.coverAsset ?? '').isNotEmpty) {
      return Image.asset(
        song.coverAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.album,
              size: 120,
              color: Colors.white70,
            ),
          );
        },
      );
    }

    if ((song.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        song.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.album,
              size: 120,
              color: Colors.white70,
            ),
          );
        },
      );
    }

    return const Center(
      child: Icon(
        Icons.album,
        size: 120,
        color: Colors.white70,
      ),
    );
  }
}

class _LyricsPreviewCard extends StatelessWidget {
  final AudioPlayerController controller;

  const _LyricsPreviewCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final lyrics = controller.lyrics;
    final currentIndex = controller.currentLyricIndex;

    List<String> previewLines;

    if (lyrics.isEmpty) {
      previewLines = ['Chưa có lời bài hát cho bài này'];
    } else {
      final start = currentIndex >= 0 ? currentIndex : 0;
      final end = (start + 4).clamp(0, lyrics.length);
      previewLines = lyrics.sublist(start, end).map((e) => e.text).toList();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF8E99A5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bản xem trước lời bài hát',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          ...previewLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: lyrics.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LyricsScreen(controller: controller),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text('Hiện lời bài hát'),
          ),
        ],
      ),
    );
  }
}