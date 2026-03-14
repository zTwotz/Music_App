import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exploreTags = [
      '#hip hop việt nam',
      '#vietnamese trap',
      '#melodic',
    ];

    final browseItems = [
      'Nhạc',
      'Podcasts',
      'Sự kiện trực tiếp',
      'Dành cho bạn',
      'Bản phát hành mới',
      'Mới phát hành',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text(
                'Tìm kiếm',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.black87),
                SizedBox(width: 10),
                Text(
                  'Bạn muốn nghe gì?',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Khám phá nội dung mới mẻ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: exploreTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(exploreTags[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Duyệt tìm tất cả',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: browseItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 110,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.primaries[index % Colors.primaries.length].shade700,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    browseItems[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}