import 'package:flutter/material.dart';
import '../models/song.dart';

class MiniPlayer extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.progress,
    required this.onTap,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Material(
        color: const Color(0xFF14532D),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 64,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            song.coverAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.music_note,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Nút bài trước
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onPrevious,
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      // Nút phát / dừng
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onPlayPause,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      // Nút bài tiếp theo
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onNext,
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 2.5,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}