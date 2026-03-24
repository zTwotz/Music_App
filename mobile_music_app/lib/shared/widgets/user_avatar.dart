import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      await context.read<AuthProvider>().updateAvatar(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoggedIn = auth.isLoggedIn;
        final name = auth.displayName;
        final avatarUrl = auth.avatarUrl;
        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return GestureDetector(
          onTap: onTap,
          onLongPress: isLoggedIn ? () => _pickAndUploadImage(context) : null,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: isLoggedIn ? const Color(0xFFF3759F) : Colors.white10,
            backgroundImage: (isLoggedIn && avatarUrl != null)
                ? NetworkImage(avatarUrl)
                : null,
            child: auth.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : (isLoggedIn && avatarUrl == null)
                    ? Text(
                        firstLetter,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: radius,
                        ),
                      )
                    : (!isLoggedIn
                        ? Icon(
                            Icons.person,
                            size: radius,
                            color: Colors.white70,
                          )
                        : null),
          ),
        );
      },
    );
  }
}
