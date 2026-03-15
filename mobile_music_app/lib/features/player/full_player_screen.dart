import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import 'lyrics_screen.dart';

class FullPlayerScreen extends StatelessWidget {
  final AudioPlayerController controller;

  const FullPlayerScreen({
    super.key,
    required this.controller,
  });

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
                        child: Image.asset(
                          song.coverAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.album,
                                size: 120,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
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
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: controller.toggleFavorite,
                          icon: Icon(
                            controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: controller.isFavorite ? Colors.red : Colors.white,
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
                            color: controller.isShuffleActive ? Colors.green : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.playPrevious,
                          icon: const Icon(Icons.skip_previous, size: 34, color: Colors.white),
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
                          icon: const Icon(Icons.skip_next, size: 34, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: controller.toggleRepeat,
                          icon: Icon(
                            controller.isRepeatActive ? Icons.repeat_one : Icons.repeat,
                            size: 28,
                            color: controller.isRepeatActive ? Colors.green : Colors.white,
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
      previewLines = lyrics
          .sublist(start, end)
          .map((e) => e.text)
          .toList();
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