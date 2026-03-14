import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';

class LyricsScreen extends StatefulWidget {
  final AudioPlayerController controller;

  const LyricsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastScrolledIndex = -1;

  void _scrollToCurrentLine(int index) {
    if (!_scrollController.hasClients || index < 0) return;

    const itemExtent = 72.0;
    final targetOffset = (index * itemExtent) - 180;

    final maxExtent = _scrollController.position.maxScrollExtent;
    final safeOffset = targetOffset.clamp(0.0, maxExtent);

    _scrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final song = widget.controller.currentSong;
        final lyrics = widget.controller.lyrics;
        final currentIndex = widget.controller.currentLyricIndex;

        if (song == null) {
          return const Scaffold(
            body: Center(
              child: Text('Chưa có bài hát nào được chọn'),
            ),
          );
        }

        if (currentIndex != _lastScrolledIndex && currentIndex >= 0) {
          _lastScrolledIndex = currentIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentLine(currentIndex);
          });
        }

        final maxSeconds = widget.controller.duration.inSeconds > 0
            ? widget.controller.duration.inSeconds.toDouble()
            : 1.0;

        final currentSeconds = widget.controller.position.inSeconds.clamp(
          0,
          widget.controller.duration.inSeconds > 0
              ? widget.controller.duration.inSeconds
              : 1,
        ).toDouble();

        return Scaffold(
          backgroundColor: const Color(0xFF8E99A5),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 30),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: lyrics.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có lời bài hát',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                          itemCount: lyrics.length,
                          itemBuilder: (context, index) {
                            final line = lyrics[index];
                            final isCurrent = index == currentIndex;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                line.text,
                                style: TextStyle(
                                  fontSize: isCurrent ? 26 : 20,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isCurrent
                                      ? Colors.black
                                      : Colors.white.withOpacity(0.95),
                                  height: 1.25,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SliderTheme(
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
                        widget.controller.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.controller.formatTime(widget.controller.position)),
                      Text(widget.controller.formatTime(widget.controller.duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: widget.controller.togglePlayPause,
                      iconSize: 38,
                      icon: Icon(
                        widget.controller.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}