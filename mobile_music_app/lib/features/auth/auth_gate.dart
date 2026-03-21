import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root/root_shell.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return const RootShell();
      },
    );
  }
}