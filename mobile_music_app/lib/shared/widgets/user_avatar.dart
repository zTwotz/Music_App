import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.radius = 18,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoggedIn = auth.isLoggedIn;
        final name = auth.displayName;
        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: isLoggedIn ? const Color(0xFFF3759F) : Colors.white10,
            child: isLoggedIn
                ? Text(
                    firstLetter,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: radius,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: radius,
                    color: Colors.white70,
                  ),
          ),
        );
      },
    );
  }
}
