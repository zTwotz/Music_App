import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../core/navigation/player_route_observer.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/create_bottom_sheet.dart';
import '../../shared/widgets/mini_player.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../catalog/podcast_catalog_provider.dart';
import '../catalog/song_catalog_provider.dart';
import '../home/home_screen.dart';
import '../library/library_screen.dart';
import '../player/full_player_screen.dart';
import '../search/search_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;
  late final AudioPlayerController _audioController;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _audioController = AudioPlayerController();
    _audioController.addListener(_rebuild);
    playerRouteObserver.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_currentIndex].currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      if (_currentIndex != 0) {
        _onTapNav(0);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  Widget _buildOffstageNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _TabScreenBuilder(
            index: index,
            audioController: _audioController,
            homeKey: index == 0 ? _homeKey : null,
          ),
        );
      },
    );
  }

  List<Song> get _currentSongs {
    return context.read<SongCatalogProvider>().allSongs;
  }

  @override
  void dispose() {
    _audioController.removeListener(_rebuild);
    playerRouteObserver.removeListener(_rebuild);
    _audioController.dispose();
    super.dispose();
  }

  void _onTapNav(int index) {
    if (index == 3) {
      _openCreateBottomSheet();
      return;
    }

    if (index == 0) {
      _homeKey.currentState?.resetFilter();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _openCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateBottomSheet(),
    );
  }

  void _openFullPlayer(List<Song> songs) {
    if (!_audioController.hasSong) return;

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        settings: const RouteSettings(
          name: PlayerRouteObserver.fullPlayerRouteName,
        ),
        builder: (_) => FullPlayerScreen(
          controller: _audioController,
          allSongs: songs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.displayName;
    final email = auth.email;

    // Check if mini player should be shown: has song AND not inside full player screen
    final showMiniPlayer =
        _audioController.hasSong && !playerRouteObserver.isFullPlayerOpen;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    UserAvatar(
                      radius: 24,
                      onTap: () {}, // Icon only inside drawer
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.isLoggedIn ? displayName : 'Chưa đăng nhập',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.isEmpty ? 'Chưa có email' : email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text(
                  'Thêm tài khoản',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.flash_on, color: Colors.white),
                title: const Text(
                  'Có gì mới',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text(
                  'Gần đây',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text(
                  'Cài đặt và quyền riêng tư',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {},
              ),
              if (context.watch<SongCatalogProvider>().isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Đang tải bài hát từ cloud...',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              if ((context.watch<SongCatalogProvider>().error ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cloud lỗi, app đang dùng nhạc local.',
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              const Divider(color: Colors.white10),
              if (auth.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().signOut();
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.greenAccent),
                  title: const Text(
                    'Đăng nhập',
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMiniPlayer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: MiniPlayer(
                song: _audioController.currentSong!,
                isPlaying: _audioController.isPlaying,
                progress: _audioController.progress,
                onTap: () => _openFullPlayer(_currentSongs),
                onPrevious: _audioController.playPrevious,
                onPlayPause: _audioController.togglePlayPause,
                onNext: _audioController.playNext,
              ),
            ),
          NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: const Color(0xFF181818),
            indicatorColor: Colors.white12,
            onDestinationSelected: _onTapNav,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Tìm kiếm',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music),
                label: 'Thư viện',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Tạo',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabScreenBuilder extends StatelessWidget {
  final int index;
  final AudioPlayerController audioController;
  final GlobalKey<HomeScreenState>? homeKey;

  const _TabScreenBuilder({
    required this.index,
    required this.audioController,
    this.homeKey,
  });

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<SongCatalogProvider>();
    final podcastCatalog = context.watch<PodcastCatalogProvider>();
    
    final songs = catalog.allSongs;
    final podcasts = podcastCatalog.allPodcasts;

    if (index == 0) {
      return HomeScreen(
        key: homeKey,
        songs: songs,
        podcasts: podcasts,
        controller: audioController,
      );
    } else if (index == 1) {
      return SearchScreen(
        controller: audioController,
        songs: songs,
        podcasts: podcasts,
      );
    } else {
      return LibraryScreen(
        controller: audioController,
        songs: songs,
        podcasts: podcasts,
      );
    }
  }
}