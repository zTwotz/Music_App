import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../artist/artist_songs_screen.dart';
import '../catalog/song_catalog_provider.dart';
import '../library/favorite_songs_screen.dart';
import '../player/full_player_screen.dart';
import '../playlist/playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Song> songs;
  final AudioPlayerController controller;

  const HomeScreen({
    super.key,
    required this.songs,
    required this.controller,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Tất cả';

  late List<Map<String, dynamic>> recentItems;
  late List<Map<String, dynamic>> dailyMixes;

  void resetFilter() {
    if (!mounted) return;
    if (_selectedFilter != 'Tất cả') {
      setState(() {
        _selectedFilter = 'Tất cả';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songs != widget.songs) {
      _initializeData();
    }
  }

  void _initializeData() {
    final random = Random();

    List<Song> getRandomSongs(int count) {
      if (widget.songs.isEmpty) return [];
      final list = List<Song>.from(widget.songs)..shuffle(random);
      return list.take(count).toList();
    }

    Map<String, dynamic> getRandomCoverInfo() {
      if (widget.songs.isEmpty) {
        return {
          'image': '',
          'isNetwork': false,
        };
      }

      final song = widget.songs[random.nextInt(widget.songs.length)];
      final asset = song.coverAsset ?? '';
      final url = song.coverUrl ?? '';

      if (asset.isNotEmpty) {
        return {
          'image': asset,
          'isNetwork': false,
        };
      }

      if (url.isNotEmpty) {
        return {
          'image': url,
          'isNetwork': true,
        };
      }

      return {
        'image': '',
        'isNetwork': false,
      };
    }

    recentItems = [
      {
        'title': 'Sơn Tùng M-TP',
        'isNetwork': false,
        'image': 'assets/covers_demo/sontung_profile.jpg',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArtistSongsScreen(
                artistName: 'Sơn Tùng MTP',
                controller: widget.controller,
                songs: widget.songs,
              ),
            ),
          );
        },
      },
      {
        'title': 'Top Hits',
        ...getRandomCoverInfo(),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistDetailScreen(
                title: 'Top Hits Vietnam',
                songs: getRandomSongs(7),
                controller: widget.controller,
                allSongs: widget.songs,
              ),
            ),
          );
        },
      },
      {
        'title': 'Chill Cuối Tuần',
        ...getRandomCoverInfo(),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistDetailScreen(
                title: 'Chill Cuối Tuần',
                songs: getRandomSongs(8),
                controller: widget.controller,
                allSongs: widget.songs,
              ),
            ),
          );
        },
      },
      {
        'title': 'Nhạc Code Đêm',
        ...getRandomCoverInfo(),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistDetailScreen(
                title: 'Nhạc Code Đêm',
                songs: getRandomSongs(10),
                controller: widget.controller,
                allSongs: widget.songs,
              ),
            ),
          );
        },
      },
      {
        'title': 'The Weeknd',
        'isNetwork': false,
        'image': 'assets/covers_demo/theweeknd_profile.jpg',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArtistSongsScreen(
                artistName: 'The Weeknd',
                controller: widget.controller,
                songs: widget.songs,
              ),
            ),
          );
        },
      },
      {
        'title': 'Bài hát đã thích',
        'isNetwork': false,
        'isFavoriteList': true,
        'image': '',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoriteSongsScreen(
                controller: widget.controller,
                songs: widget.songs,
              ),
            ),
          );
        },
      },
    ];

    dailyMixes = [
      {
        'title': 'Giai Điệu Thư Giãn',
        ...getRandomCoverInfo(),
        'songs': getRandomSongs(12),
      },
      {
        'title': 'Năng Lượng Tích Cực',
        ...getRandomCoverInfo(),
        'songs': getRandomSongs(15),
      },
      {
        'title': 'Chìm Đắm Suy Tư',
        ...getRandomCoverInfo(),
        'songs': getRandomSongs(9),
      },
      {
        'title': 'Trạm Sạc Cảm Xúc',
        ...getRandomCoverInfo(),
        'songs': getRandomSongs(11),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<SongCatalogProvider>().refreshSongs(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFF3759F),
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildTopChip(
                    'Tất cả',
                    isSelected: _selectedFilter == 'Tất cả',
                    isOutlined: _selectedFilter != 'Tất cả',
                    onTap: () => setState(() => _selectedFilter = 'Tất cả'),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedFilter.startsWith('Âm nhạc')) ...[
                    _buildJoinedChip(
                      leftLabel: 'Âm nhạc',
                      rightLabel: 'Đang theo dõi',
                      leftActiveColor: const Color(0xFF90CEFA),
                      rightActiveColor: const Color(0xFF90CEFA),
                      isLeftActive: _selectedFilter == 'Âm nhạc',
                      onLeftTap: () => setState(() => _selectedFilter = 'Âm nhạc'),
                      onRightTap: () => setState(
                        () => _selectedFilter = 'Âm nhạc - Đang theo dõi',
                      ),
                    ),
                  ] else ...[
                    _buildTopChip(
                      'Âm nhạc',
                      isSelected: false,
                      isOutlined: _selectedFilter != 'Tất cả',
                      onTap: () => setState(() => _selectedFilter = 'Âm nhạc'),
                    ),
                  ],
                  const SizedBox(width: 8),
                  if (_selectedFilter.startsWith('Podcasts')) ...[
                    _buildJoinedChip(
                      leftLabel: 'Podcasts',
                      rightLabel: 'Đang theo dõi',
                      leftActiveColor: const Color(0xFF1ED760),
                      rightActiveColor: const Color(0xFF1ED760),
                      isLeftActive: _selectedFilter == 'Podcasts',
                      onLeftTap: () => setState(() => _selectedFilter = 'Podcasts'),
                      onRightTap: () => setState(
                        () => _selectedFilter = 'Podcasts - Đang theo dõi',
                      ),
                    ),
                  ] else ...[
                    _buildTopChip(
                      'Podcasts',
                      isSelected: false,
                      isOutlined: _selectedFilter != 'Tất cả',
                      onTap: () => setState(() => _selectedFilter = 'Podcasts'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedFilter == 'Âm nhạc - Đang theo dõi') ...[
              const Text(
                'Bài hát từ nghệ sĩ bạn theo dõi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.songs.where((song) {
                final artist = song.artist.toLowerCase();
                return widget.controller.followedArtistNames.any(
                  (f) => artist.contains(f.toLowerCase()),
                );
              }).map((song) => _buildSongItem(song)),
              if (widget.songs.where((song) {
                final artist = song.artist.toLowerCase();
                return widget.controller.followedArtistNames.any(
                  (f) => artist.contains(f.toLowerCase()),
                );
              }).isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Bạn chưa theo dõi nghệ sĩ nào\nhoặc nghệ sĩ đó chưa có bài hát.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
            ] else ...[
              const Text(
                'Nghe gần đây',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: recentItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 56,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final item = recentItems[index];

                return AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    String displayImage = item['image'] as String? ?? '';
                    bool isNetwork = item['isNetwork'] as bool? ?? false;

                    if (item['isFavoriteList'] == true) {
                      if (widget.controller.favoriteSongIds.isNotEmpty &&
                          widget.songs.isNotEmpty) {
                        final firstId = widget.controller.favoriteSongIds.first;
                        final song = widget.songs.firstWhere(
                          (s) => s.id == firstId,
                          orElse: () => widget.songs.first,
                        );

                        displayImage = song.coverAsset ?? song.coverUrl ?? '';
                        isNetwork = (song.coverAsset ?? '').isEmpty &&
                            (song.coverUrl ?? '').isNotEmpty;
                      } else {
                        displayImage = '';
                        isNetwork = false;
                      }
                    }

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: item['onTap'] as VoidCallback?,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF242424),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: displayImage.isEmpty
                                    ? Container(
                                        color: Colors.white10,
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.white70,
                                        ),
                                      )
                                    : _buildImageByPath(
                                        displayImage,
                                        isNetwork: isNetwork,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['title'] as String? ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Khơi nguồn cảm hứng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dailyMixes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final mix = dailyMixes[index];
                  final image = mix['image'] as String? ?? '';
                  final isNetwork = mix['isNetwork'] as bool? ?? false;
                  final songs = mix['songs'] as List<Song>? ?? [];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistDetailScreen(
                            title: mix['title'] as String? ?? '',
                            songs: songs,
                            controller: widget.controller,
                            allSongs: widget.songs,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: image.isEmpty
                                ? const Center(
                                    child: Icon(
                                      Icons.album,
                                      size: 48,
                                      color: Colors.white70,
                                    ),
                                  )
                                : _buildImageByPath(
                                    image,
                                    isNetwork: isNetwork,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mix['title'] as String? ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Danh sách các bài hát',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.songs.map((song) => _buildSongItem(song)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(Song song) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isCurrentSong = widget.controller.currentSong?.id == song.id;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            widget.controller.selectSong(song, queue: widget.songs);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullPlayerScreen(
                  controller: widget.controller,
                  allSongs: widget.songs,
                ),
              ),
            );
          },
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isCurrentSong ? Colors.green.withOpacity(0.3) : Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildSongCover(song),
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrentSong ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(song.artist),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentSong)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedEqualizer(
                    isPlaying: widget.controller.isPlaying,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showSongOptionsBottomSheet(
                  context,
                  song: song,
                  controller: widget.controller,
                  allSongs: widget.songs,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongCover(Song song) {
    if ((song.coverAsset ?? '').isNotEmpty) {
      return Image.asset(
        song.coverAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.music_note, color: Colors.white70);
        },
      );
    }

    if ((song.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        song.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.music_note, color: Colors.white70);
        },
      );
    }

    return const Icon(Icons.music_note, color: Colors.white70);
  }

  Widget _buildImageByPath(
    String path, {
    required bool isNetwork,
    double? width,
    double? height,
  }) {
    if (isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            color: Colors.white10,
            child: const Icon(Icons.music_note),
          );
        },
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: Colors.white10,
          child: const Icon(Icons.music_note),
        );
      },
    );
  }

  Widget _buildTopChip(
    String label, {
    bool isSelected = false,
    bool isOutlined = false,
    VoidCallback? onTap,
  }) {
    Color bgColor = const Color(0xFF2A2A2A);
    Color textColor = Colors.white;
    Border? border;

    if (isSelected) {
      if (label == 'Âm nhạc') {
        bgColor = const Color(0xFF90CEFA);
      } else {
        bgColor = const Color(0xFF1ED760);
      }
      textColor = Colors.black;
    } else if (isOutlined) {
      bgColor = Colors.transparent;
      border = Border.all(color: Colors.white70, width: 1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildJoinedChip({
    required String leftLabel,
    required String rightLabel,
    required Color leftActiveColor,
    required Color rightActiveColor,
    required bool isLeftActive,
    required VoidCallback onLeftTap,
    required VoidCallback onRightTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onLeftTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLeftActive ? leftActiveColor : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                leftLabel,
                style: TextStyle(
                  color: isLeftActive ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onRightTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !isLeftActive ? rightActiveColor : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                rightLabel,
                style: TextStyle(
                  color: !isLeftActive ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}