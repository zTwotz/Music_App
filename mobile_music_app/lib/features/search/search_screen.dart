import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../core/navigation/player_navigator.dart';
import '../../core/services/artist_service.dart';
import '../artist/artist_songs_screen.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../shared/models/song.dart';
import '../../shared/models/artist.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../catalog/podcast_catalog_provider.dart';
import '../catalog/song_catalog_provider.dart';

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
  List<Artist> _filteredArtists = [];
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

  String _normalize(String str) {
    const accents =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const noAccents =
        'aaaaaaaaaaaaeeseiaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyd';

    String result = str.toLowerCase();
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], noAccents[i]);
    }
    // Remove all non-alphanumeric characters and collapse double letters (greedy normalization)
    result = result.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Common Vietnamese Telex double keys: aa->a, ee->e, oo->o, dd->d, uw->u
    result = result
        .replaceAll('aa', 'a')
        .replaceAll('ee', 'e')
        .replaceAll('oo', 'o')
        .replaceAll('dd', 'd')
        .replaceAll('uu', 'u')
        .replaceAll('ww', 'w')
        .replaceAll('uw', 'u');

    return result;
  }

  void _onSearchChanged() async {
    final rawQuery = _searchController.text.trim();
    if (rawQuery.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredSongs = [];
        _filteredArtists = [];
      });
      return;
    }

    final query = _normalize(rawQuery);
    final combined = [...widget.songs, ...widget.podcasts];

    // Priority search for artists
    final artists = await ArtistService().searchArtists(rawQuery);

    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _filteredArtists = artists;
      _filteredSongs = combined.where((item) {
        final titleNorm = _normalize(item.title);
        final artistNorm = _normalize(item.artist);

        return titleNorm.contains(query) || artistNorm.contains(query);
      }).toList();
    });
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
      _filteredArtists = [];
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
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isLoggedIn = auth.isLoggedIn;
                        final name = auth.displayName;
                        final firstLetter =
                            name.isNotEmpty ? name[0].toUpperCase() : '?';

                        return GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: isLoggedIn
                                ? const Color(0xFFF3759F)
                                : Colors.white10,
                            child: isLoggedIn
                                ? Text(
                                    firstLetter,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 18, color: Colors.white70),
                          ),
                        );
                      },
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
                        'Kết quả tìm kiếm',
                        style: TextStyle(
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
                  if (_filteredArtists.isNotEmpty) ...[
                    ..._filteredArtists.map((artist) => _buildArtistItem(artist)),
                    const SizedBox(height: 16),
                  ],
                  if (_filteredSongs.isEmpty && _filteredArtists.isEmpty)
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
                          pushFullPlayer(
                            context,
                            controller: widget.controller,
                            allSongs: widget.songs,
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

  Widget _buildArtistItem(Artist artist) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistSongsScreen(
              artistName: artist.name,
              avatarUrl: artist.avatarUrl,
              controller: widget.controller,
              songs: widget.songs,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white10,
        backgroundImage: (artist.avatarUrl != null && artist.avatarUrl!.isNotEmpty)
            ? NetworkImage(artist.avatarUrl!)
            : null,
        child: (artist.avatarUrl == null || artist.avatarUrl!.isEmpty)
            ? const Icon(Icons.person, color: Colors.white54)
            : null,
      ),
      title: Text(
        artist.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: const Text(
        'Nghệ sĩ',
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
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