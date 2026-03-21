import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../core/utils/string_utils.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../catalog/podcast_catalog_provider.dart';
import '../catalog/song_catalog_provider.dart';
import '../player/full_player_screen.dart';

class SearchScreen extends StatefulWidget {
  final AudioPlayerController controller;
  final List<Song> songs;
  final List<Podcast> podcasts;

  const SearchScreen({
    super.key,
    required this.controller,
    required this.songs,
    required this.podcasts,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Song> _filteredSongs = [];
  bool _isSearching = false;

  final List<String> exploreTags = [
    '#hip hop việt nam',
    '#vietnamese trap',
    '#melodic',
    '#rap việt',
    '#r&b',
  ];

  late List<Map<String, dynamic>> browseItems;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeBrowseItems();
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songs != widget.songs) {
      _initializeBrowseItems();
      _onSearchChanged();
    }
  }

  void _initializeBrowseItems() {
    final random = Random();
    final songs = widget.songs;

    if (songs.isEmpty) {
      browseItems = [];
      return;
    }

    browseItems = [
      {'title': 'Nhạc', 'song': songs[random.nextInt(songs.length)]},
      {'title': 'Podcasts', 'song': widget.podcasts.isNotEmpty ? widget.podcasts[random.nextInt(widget.podcasts.length)] : songs[random.nextInt(songs.length)]},
      {'title': 'Sự kiện trực tiếp', 'song': songs[random.nextInt(songs.length)]},
      {'title': 'Dành cho bạn', 'song': songs[random.nextInt(songs.length)]},
      {'title': 'Bản phát hành mới', 'song': songs[random.nextInt(songs.length)]},
      {'title': 'Mới phát hành', 'song': songs[random.nextInt(songs.length)]},
    ];
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    final queryNormalized = removeDiacritics(query);

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredSongs = [];
      });
    } else {
      final combined = [...widget.songs, ...widget.podcasts];
      final queryWords = queryNormalized.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

      setState(() {
        _isSearching = true;
        _filteredSongs = combined.where((item) {
          final titleNormalized = removeDiacritics(item.title.toLowerCase());
          final artistNormalized = removeDiacritics(item.artist.toLowerCase());

          // Check for exact substring match first (most relevant)
          if (titleNormalized.contains(queryNormalized) ||
              artistNormalized.contains(queryNormalized)) {
            return true;
          }

          // Check if all words in query appear in either title or artist
          if (queryWords.isNotEmpty) {
            return queryWords.every((word) =>
                titleNormalized.contains(word) ||
                artistNormalized.contains(word));
          }

          return false;
        }).toList()
          ..sort((a, b) {
            final aTitle = removeDiacritics(a.title.toLowerCase());
            final bTitle = removeDiacritics(b.title.toLowerCase());
            final aArtist = removeDiacritics(a.artist.toLowerCase());
            final bArtist = removeDiacritics(b.artist.toLowerCase());

            final aScore = _getMatchScore(aTitle, aArtist, queryNormalized);
            final bScore = _getMatchScore(bTitle, bArtist, queryNormalized);

            return bScore.compareTo(aScore); // Higher score first
          });
      });
    }
  }

  int _getMatchScore(String title, String artist, String query) {
    int score = 0;

    // Direct substring match at start of title or artist (highest)
    if (title.startsWith(query)) score += 100;
    if (artist.startsWith(query)) score += 80;

    // Direct substring match anywhere in title or artist
    if (title.contains(query)) score += 50;
    if (artist.contains(query)) score += 30;

    // Bonus for exact field match
    if (title == query) score += 200;
    if (artist == query) score += 150;

    return score;
  }

  void _handleTagSelection(String tag) {
    _searchController.text = tag;
    _searchFocusNode.unfocus();
    _showRandomSongs();
  }

  void _showRandomSongs() {
    final random = Random();
    final combined = [...widget.songs, ...widget.podcasts];
    final randomContent = List<Song>.from(combined)..shuffle(random);

    setState(() {
      _isSearching = true;
      _filteredSongs = randomContent.take(15).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<SongCatalogProvider>().refreshSongs();
              await context.read<PodcastCatalogProvider>().refreshPodcasts();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              children: [
                Row(
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
                    const Text(
                      'Tìm kiếm',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Bạn muốn nghe gì?',
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black87),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (!_isSearching) ...[
                  const Text(
                    'Khám phá nội dung mới mẻ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: exploreTags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _handleTagSelection(exploreTags[index]),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              exploreTags[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Duyệt tìm tất cả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    itemCount: browseItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 100,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemBuilder: (context, index) {
                      final item = browseItems[index];
                      final song = item['song'] as Song;

                      return GestureDetector(
                        onTap: () {
                          _searchController.text =
                              item['title'] as String? ?? '';
                          _searchFocusNode.unfocus();
                          _showRandomSongs();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildSongCover(song),
                              ),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    item['title'] as String? ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gợi ý cho bạn',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchFocusNode.unfocus();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_filteredSongs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'Không tìm thấy kết quả nào',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    ..._filteredSongs.map((song) {
                      final isCurrentSong =
                          widget.controller.currentSong?.id == song.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          widget.controller
                              .selectSong(song, queue: _filteredSongs);
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 52,
                            height: 52,
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
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(color: Colors.white70),
                        ),
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
                    }),
                ],
              ],
            ),
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
          return Container(
            color: Colors.white10,
            child: const Icon(Icons.music_note),
          );
        },
      );
    }

    if ((song.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        song.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: Colors.white10,
            child: const Icon(Icons.music_note),
          );
        },
      );
    }

    return Container(
      color: Colors.white10,
      child: const Icon(Icons.music_note),
    );
  }
}