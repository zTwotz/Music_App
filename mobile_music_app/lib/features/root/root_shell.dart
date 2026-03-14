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

  void _playPreviousSong() {
    if (!_audioController.hasSong || demoSongs.isEmpty) return;

    final currentSong = _audioController.currentSong;
    if (currentSong == null) return;

    final currentIndex = demoSongs.indexWhere((song) => song.id == currentSong.id);
    if (currentIndex == -1) return;

    final previousIndex = currentIndex > 0 ? currentIndex - 1 : demoSongs.length - 1;
    _audioController.selectSong(demoSongs[previousIndex]);
  }

  void _playNextSong() {
    if (!_audioController.hasSong || demoSongs.isEmpty) return;

    final currentSong = _audioController.currentSong;
    if (currentSong == null) return;

    final currentIndex = demoSongs.indexWhere((song) => song.id == currentSong.id);
    if (currentIndex == -1) return;

    final nextIndex = currentIndex < demoSongs.length - 1 ? currentIndex + 1 : 0;
    _audioController.selectSong(demoSongs[nextIndex]);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        songs: demoSongs,
        currentSongId: _audioController.currentSong?.id,
        onSelectSong: _audioController.selectSong,
      ),
      const SearchScreen(),
      const LibraryScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return AnimatedBuilder(
      animation: _audioController,
      builder: (context, _) {
        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_audioController.hasSong)
                MiniPlayer(
                  song: _audioController.currentSong!,
                  isPlaying: _audioController.isPlaying,
                  progress: _audioController.progress,
                  onTap: _openFullPlayer,
                  onPrevious: _playPreviousSong,
                  onPlayPause: _audioController.togglePlayPause,
                  onNext: _playNextSong,
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
      },
    );
  }
}