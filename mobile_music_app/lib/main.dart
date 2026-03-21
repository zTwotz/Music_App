import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/services/auth_service.dart';
import 'core/services/song_service.dart';
import 'core/services/supabase_config.dart';
import 'features/auth/auth_provider.dart';
import 'features/catalog/podcast_catalog_provider.dart';
import 'features/catalog/song_catalog_provider.dart';
import 'core/services/podcast_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
          )..bootstrap(),
        ),
        ChangeNotifierProvider(
          create: (_) => SongCatalogProvider(
            songService: SongService(),
          )..loadSongs(),
        ),
        ChangeNotifierProvider(
          create: (_) => PodcastCatalogProvider(
            podcastService: PodcastService(),
          )..loadPodcasts(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}