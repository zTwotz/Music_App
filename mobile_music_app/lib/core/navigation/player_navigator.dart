import 'package:flutter/material.dart';

import '../../features/player/full_player_screen.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/models/song.dart';
import 'player_route_observer.dart';

/// Helper để push [FullPlayerScreen] với route name đúng.
/// Luôn dùng hàm này thay vì push trực tiếp để mini player tự ẩn.
Future<void> pushFullPlayer(
  BuildContext context, {
  required AudioPlayerController controller,
  required List<Song> allSongs,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(
        name: PlayerRouteObserver.fullPlayerRouteName,
      ),
      builder: (_) => FullPlayerScreen(
        controller: controller,
        allSongs: allSongs,
      ),
    ),
  );
}
