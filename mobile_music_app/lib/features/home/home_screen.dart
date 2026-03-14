import 'package:flutter/material.dart';
import '../../shared/models/song.dart';

class HomeScreen extends StatelessWidget {
  final List<Song> songs;
  final String? currentSongId;
  final Future<void> Function(Song) onSelectSong;

  const HomeScreen({
    super.key,
    required this.songs,
    required this.currentSongId,
    required this.onSelectSong,
  });

  @override
  Widget build(BuildContext context) {
    final recentItems = [
      'Sơn Tùng M-TP',
      'Top Hits Vietnam',
      'Chill Cuối Tuần',
      'Nhạc Code Đêm',
      'The Weeknd',
      'Bài hát đã thích',
    ];

    final dailyMixes = [
      'Nhạc hay mỗi ngày #1',
      'Nhạc hay mỗi ngày #2',
      'Nhạc hay mỗi ngày #3',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              _buildTopChip('Tất cả', isSelected: true),
              const SizedBox(width: 8),
              _buildTopChip('Âm nhạc'),
              const SizedBox(width: 8),
              _buildTopChip('Podcasts'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nghe gần đây',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: recentItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.music_note, color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recentItems[index],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Nhạc hay mỗi ngày cho bạn',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dailyMixes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.album, size: 48, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dailyMixes[index],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '20 bài offline để test',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...songs.map(
            (song) => ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => onSelectSong(song),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: currentSongId == song.id
                      ? Colors.green.withOpacity(0.3)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    song.coverAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.music_note, color: Colors.white70);
                    },
                  ),
                ),
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              trailing: Icon(
                currentSongId == song.id ? Icons.equalizer : Icons.more_vert,
                color: currentSongId == song.id ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}