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
import 'core/services/profile_service.dart';
import 'core/services/home_service.dart';
import 'features/home/home_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
            profileService: ProfileService(),
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
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            homeService: HomeService(),
          )..fetchInspiration(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}