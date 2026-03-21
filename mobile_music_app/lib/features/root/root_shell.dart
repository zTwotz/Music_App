import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/create_bottom_sheet.dart';
import '../../shared/widgets/mini_player.dart';
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

  @override
  void initState() {
    super.initState();
    _audioController = AudioPlayerController();
  }

  @override
  void dispose() {
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

    Navigator.push(
      context,
      MaterialPageRoute(
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
    final catalog = context.watch<SongCatalogProvider>();
    final podcastCatalog = context.watch<PodcastCatalogProvider>();

    final songs = catalog.allSongs;
    final podcasts = podcastCatalog.allPodcasts;

    final displayName = auth.displayName;
    final email = auth.email;
    final avatarLetter =
        displayName.isNotEmpty ? displayName.characters.first.toUpperCase() : 'U';

    final screens = [
      HomeScreen(
        key: _homeKey,
        songs: songs,
        podcasts: podcasts,
        controller: _audioController,
      ),
      SearchScreen(
        controller: _audioController,
        songs: songs,
        podcasts: podcasts,
      ),
      LibraryScreen(
        controller: _audioController,
        songs: songs,
        podcasts: podcasts,
      ),
    ];

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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: auth.isLoggedIn
                          ? const Color(0xFFF3759F)
                          : Colors.white10,
                      child: auth.isLoggedIn
                          ? Text(
                              avatarLetter,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 24, color: Colors.white70),
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
              if (catalog.isLoading)
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
              if ((catalog.error ?? '').isNotEmpty)
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
      body: screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _audioController,
            builder: (context, _) {
              if (_audioController.hasSong) {
                return MiniPlayer(
                  song: _audioController.currentSong!,
                  isPlaying: _audioController.isPlaying,
                  progress: _audioController.progress,
                  onTap: () => _openFullPlayer(songs),
                  onPrevious: _audioController.playPrevious,
                  onPlayPause: _audioController.togglePlayPause,
                  onNext: _audioController.playNext,
                );
              }
              return const SizedBox.shrink();
            },
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