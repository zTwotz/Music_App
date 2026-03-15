import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/widgets/create_bottom_sheet.dart';
import '../../shared/widgets/mini_player.dart';
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

  void _openFullPlayer() {
    if (!_audioController.hasSong) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullPlayerScreen(controller: _audioController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: _homeKey,
        songs: demoSongs,
        controller: _audioController,
      ),
      SearchScreen(
        controller: _audioController,
        songs: demoSongs,
      ),
      LibraryScreen(controller: _audioController),
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
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFF3759F),
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Twot Nguyễn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Xem hồ sơ',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Thêm tài khoản', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.flash_on, color: Colors.white),
                title: const Text('Có gì mới', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.white),
                title: Row(
                  children: const [
                    Text('Số liệu hoạt động nghe', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8),
                    Text('• Mới', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text('Gần đây', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none, color: Colors.white),
                title: Row(
                  children: const [
                    Text('Tin cập nhật', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8),
                    Text('• Mới', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                  ],
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text('Cài đặt và quyền riêng tư', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
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
                  onTap: _openFullPlayer,
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