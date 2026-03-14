import 'package:flutter/material.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 22),
            _CreateActionTile(
              icon: Icons.queue_music,
              title: 'Danh sách phát',
              subtitle: 'Tạo playlist cá nhân mới',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _CreateActionTile(
              icon: Icons.group,
              title: 'Danh sách phát cộng tác',
              subtitle: 'Tính năng sẽ làm sau',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _CreateActionTile(
              icon: Icons.auto_awesome,
              title: 'Giai điệu chung',
              subtitle: 'Tính năng sẽ làm sau',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white10,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}