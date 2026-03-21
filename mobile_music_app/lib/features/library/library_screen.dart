import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../shared/models/song.dart';
import '../artist/artist_songs_screen.dart';
import '../catalog/podcast_catalog_provider.dart';
import '../catalog/song_catalog_provider.dart';
import '../playlist/playlist_detail_screen.dart';
import '../player/full_player_screen.dart';
import 'favorite_songs_screen.dart';

class LibraryScreen extends StatefulWidget {
  final AudioPlayerController controller;
  final List<Song> songs;
  final List<Podcast> podcasts;

  const LibraryScreen({
    super.key,
    required this.controller,
    required this.songs,
    required this.podcasts,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _activeFilter = 'Tất cả';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Tạo danh sách phát mới',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tên danh sách phát',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                widget.controller.createPlaylist(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Tạo',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractIndividualArtists(String artistStr) {
    final normalized = artistStr.replaceAll(
      RegExp(
        r'\s+(ft\.?|feat\.?|x|&|-)\s+|,\s*',
        caseSensitive: false,
      ),
      '|||',
    );

    return normalized
        .split('|||')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _getSongDisplayImage(Song song) {
    if ((song.coverAsset ?? '').isNotEmpty) return song.coverAsset;
    if ((song.coverUrl ?? '').isNotEmpty) return song.coverUrl;
    return null;
  }

  bool _isNetworkImage(String? path) {
    if (path == null || path.isEmpty) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final favoriteCount = widget.controller.favoriteSongIds.length;

        final allArtistsSet = <String>{};
        for (final song in widget.songs) {
          allArtistsSet.addAll(_extractIndividualArtists(song.artist));
        }
        
        final followedArtists = allArtistsSet.where((name) => widget.controller.followedArtistNames.contains(name.trim())).toList();
        final sortedArtists = followedArtists..sort();

        final playlists = widget.controller.playlists.keys.map((name) {
          final songIds = widget.controller.playlists[name]!;
          String? coverImage;

          if (songIds.isNotEmpty) {
            try {
              final song = widget.songs.firstWhere((s) => s.id == songIds.first);
              coverImage = _getSongDisplayImage(song);
            } catch (_) {
              coverImage = null;
            }
          } else if (widget.songs.isNotEmpty) {
            final random = Random(name.hashCode);
            final song = widget.songs[random.nextInt(widget.songs.length)];
            coverImage = _getSongDisplayImage(song);
          }

          return {
            'id': name,
            'title': name,
            'subtitle': 'Danh sách phát • Bạn • ${songIds.length} bài hát',
            'type': 'Playlist',
            'image': coverImage,
            'isNetwork': _isNetworkImage(coverImage),
          };
        }).toList();

        final List<Map<String, dynamic>> allItems = [
          {
            'id': 'favorites',
            'title': 'Bài hát đã thích',
            'subtitle': 'Danh sách phát • $favoriteCount bài hát',
            'type': 'Playlist',
            'isSpecial': true,
            'image': favoriteCount > 0 && widget.songs.isNotEmpty
                ? _getSongDisplayImage(
                    widget.songs.firstWhere(
                      (s) => widget.controller.favoriteSongIds.contains(s.id),
                      orElse: () => widget.songs.first,
                    ),
                  )
                : null,
            'isNetwork': favoriteCount > 0 && widget.songs.isNotEmpty
                ? _isNetworkImage(
                    _getSongDisplayImage(
                      widget.songs.firstWhere(
                        (s) => widget.controller.favoriteSongIds.contains(s.id),
                        orElse: () => widget.songs.first,
                      ),
                    ),
                  )
                : false,
          },
          ...playlists,
          ...sortedArtists.map((name) {
            String? artistImage;
            try {
              final song = widget.songs.firstWhere((s) {
                final individual = _extractIndividualArtists(s.artist);
                return individual.contains(name);
              });
              artistImage = _getSongDisplayImage(song);
            } catch (_) {
              artistImage = null;
            }

            return {
              'id': 'artist_$name',
              'title': name,
              'subtitle': 'Nghệ sĩ',
              'type': 'Artist',
              'image': artistImage,
              'isNetwork': _isNetworkImage(artistImage),
            };
          }),
          ...widget.podcasts.map((p) {
            final cover = p.coverAsset ?? p.coverUrl;
            return {
              'id': p.id,
              'title': p.title,
              'subtitle': 'Podcast • ${p.artist}',
              'type': 'Podcast',
              'image': cover,
              'isNetwork': _isNetworkImage(cover),
              'podcast': p,
            };
          }),
        ];

        var filteredItems = allItems;
        if (_activeFilter == 'Danh sách phát') {
          filteredItems =
              allItems.where((item) => item['type'] == 'Playlist').toList();
        } else if (_activeFilter == 'Nghệ sĩ') {
          filteredItems =
              allItems.where((item) => item['type'] == 'Artist').toList();
        } else if (_activeFilter == 'Podcasts') {
          filteredItems =
              allItems.where((item) => item['type'] == 'Podcast').toList();
        }

        if (_isSearching && _searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          filteredItems = filteredItems.where((item) {
            return item['title'].toString().toLowerCase().contains(query);
          }).toList();
        }

        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFF3759F),
                        child: Text(
                          'T',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _isSearching
                          ? TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (val) => setState(() {}),
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Tìm trong thư viện...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            )
                          : const Text(
                              'Thư viện',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) _searchController.clear();
                        });
                      },
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search_outlined,
                      ),
                    ),
                    IconButton(
                      onPressed: _showCreatePlaylistDialog,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              if (!_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Danh sách phát'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nghệ sĩ'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Podcasts'),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.swap_vert, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      'Gần đây',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<SongCatalogProvider>().refreshSongs();
                    await context.read<PodcastCatalogProvider>().refreshPodcasts();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final bool isSpecial = item['isSpecial'] == true;
                      final bool isArtist = item['type'] == 'Artist';
                      final String? imagePath = item['image'] as String?;
                      final bool isNetwork = item['isNetwork'] as bool? ?? false;

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        onTap: () {
                          if (isSpecial) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FavoriteSongsScreen(
                                  controller: widget.controller,
                                  songs: widget.songs,
                                ),
                              ),
                            );
                          } else if (item['type'] == 'Podcast') {
                            final podcast = item['podcast'] as Podcast;
                            widget.controller.selectSong(podcast, queue: widget.podcasts);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullPlayerScreen(
                                  controller: widget.controller,
                                  allSongs: widget.songs,
                                ),
                              ),
                            );
                          } else if (isArtist) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArtistSongsScreen(
                                  artistName: item['title'],
                                  controller: widget.controller,
                                  songs: widget.songs,
                                ),
                              ),
                            );
                          } else {
                            final songIds =
                                widget.controller.playlists[item['id']]!;
                            final playlistSongs = widget.songs
                                .where((s) => songIds.contains(s.id))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlaylistDetailScreen(
                                  title: item['title'],
                                  songs: playlistSongs,
                                  controller: widget.controller,
                                  allSongs: widget.songs,
                                ),
                              ),
                            );
                          }
                        },
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSpecial ? null : const Color(0xFF282828),
                            gradient: isSpecial && imagePath == null
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF450AF5),
                                      Color(0xFFC4EFD9),
                                    ],
                                  )
                                : null,
                            shape:
                                isArtist ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius:
                                isArtist ? null : BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imagePath != null
                              ? _buildImageByPath(
                                  imagePath,
                                  isNetwork: isNetwork,
                                )
                              : Icon(
                                  isSpecial
                                      ? Icons.favorite
                                      : (isArtist
                                          ? Icons.person
                                          : Icons.music_note),
                                  color: Colors.white,
                                  size: isSpecial ? 28 : 24,
                                ),
                        ),
                        title: Text(
                          item['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item['subtitle'],
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageByPath(
    String path, {
    required bool isNetwork,
  }) {
    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.white10,
          child: const Icon(Icons.music_note),
        ),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.white10,
        child: const Icon(Icons.music_note),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _activeFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF1ED760) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}