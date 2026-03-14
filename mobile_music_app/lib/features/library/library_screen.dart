import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryItems = [
      {'title': 'Bài hát đã thích', 'subtitle': 'Danh sách phát • Hệ thống'},
      {'title': 'Nhạc chill đêm', 'subtitle': 'Danh sách phát • Bạn'},
      {'title': 'Top bài hát năm 2025', 'subtitle': 'Danh sách phát • Bạn'},
      {'title': 'Billie Eilish', 'subtitle': 'Nghệ sĩ'},
      {'title': 'RPT MCK', 'subtitle': 'Nghệ sĩ'},
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
              const Expanded(
                child: Text(
                  'Thư viện',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildChip('Danh sách phát'),
              const SizedBox(width: 8),
              _buildChip('Nghệ sĩ'),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.swap_vert),
              SizedBox(width: 6),
              Text('Gần đây'),
            ],
          ),
          const SizedBox(height: 10),
          ...libraryItems.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.library_music, color: Colors.white70),
              ),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}