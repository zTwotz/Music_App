import 'package:flutter/material.dart';
import '../core/navigation/player_route_observer.dart';
import '../features/root/root_shell.dart';

/// Globally accessible observer so [RootShell] and other widgets
/// can react to [FullPlayerScreen] being pushed/popped.
final playerRouteObserver = PlayerRouteObserver();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Music App',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [playerRouteObserver],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}