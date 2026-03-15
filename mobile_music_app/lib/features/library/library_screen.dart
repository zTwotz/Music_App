import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/audio/audio_player_controller.dart';

import '../../shared/data/demo_songs.dart';
import '../artist/artist_songs_screen.dart';
import '../playlist/playlist_detail_screen.dart';
import 'favorite_songs_screen.dart';


class LibraryScreen extends StatefulWidget {
  final AudioPlayerController controller;

  const LibraryScreen({
    super.key,
    required this.controller,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _activeFilter = 'Tất cả';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Tạo danh sách phát mới', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tên danh sách phát',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                widget.controller.createPlaylist(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final favoriteCount = widget.controller.favoriteSongIds.length;

        // Extract unique artists from demoSongs for display
        final artists = demoSongs.map((s) => s.artist).toSet().toList();

        // Helper to extract individual artists cleanly
        List<String> extractIndividualArtists(String artistStr) {
          String normalized = artistStr.replaceAll(RegExp(r'\s+(ft\.?|feat\.?|x|&|-)\s+|,\s*', caseSensitive: false), '|||');
          return normalized.split('|||').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }

        // Extract all individual unique artists and sort them
        final allArtistsSet = <String>{};
        for (var song in demoSongs) {
          allArtistsSet.addAll(extractIndividualArtists(song.artist));
        }
        final sortedArtists = allArtistsSet.toList()..sort();

        final playlists = widget.controller.playlists.keys.map((name) {
          final songIds = widget.controller.playlists[name]!;
          // Find a cover image for the playlist
          String? coverImage;
          if (songIds.isNotEmpty) {
            final song = demoSongs.firstWhere((s) => s.id == songIds.first);
            coverImage = song.coverAsset;
          } else {
            // Fallback: Use a random song cover for system playlists to make it look better
            final random = Random(name.hashCode);
            coverImage = demoSongs[random.nextInt(demoSongs.length)].coverAsset;
          }

          return {
            'id': name,
            'title': name,
            'subtitle': 'Danh sách phát • Bạn • ${songIds.length} bài hát',
            'type': 'Playlist',
            'image': coverImage,
          };
        }).toList();

        final List<Map<String, dynamic>> allItems = [

          {
            'id': 'favorites',
            'title': 'Bài hát đã thích',
            'subtitle': 'Danh sách phát • $favoriteCount bài hát',
            'type': 'Playlist',
            'isSpecial': true,
            'image': favoriteCount > 0 
                ? demoSongs.firstWhere((s) => widget.controller.favoriteSongIds.contains(s.id)).coverAsset 
                : null,
          },
          ...playlists,
          ...sortedArtists.map((name) {
            // Find artist profile image or use a song cover
            String? artistImage;
            if (name == 'Sơn Tùng MTP' || name == 'Sơn Tùng M-TP') {
              artistImage = 'assets/covers_demo/sontung_profile.jpg';
            } else if (name == 'The Weeknd') {
              artistImage = 'assets/covers_demo/theweeknd_profile.jpg';
            } else {
              // Get cover of first song found for this artist
              try {
                final song = demoSongs.firstWhere((s) {
                  final individual = extractIndividualArtists(s.artist);
                  return individual.contains(name);
                });
                artistImage = song.coverAsset;
              } catch (_) {
                artistImage = null;
              }
            }

            return {
              'id': 'artist_$name',
              'title': name,
              'subtitle': 'Nghệ sĩ',
              'type': 'Artist',
              'image': artistImage,
            };
          }),
        ];



        // Apply filters
        var filteredItems = allItems;
        if (_activeFilter == 'Danh sách phát') {
          filteredItems = allItems.where((item) => item['type'] == 'Playlist').toList();
        } else if (_activeFilter == 'Nghệ sĩ') {
          filteredItems = allItems.where((item) => item['type'] == 'Artist').toList();
        }

        // Apply search
        if (_isSearching && _searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          filteredItems = filteredItems.where((item) {
            return item['title'].toString().toLowerCase().contains(query);
          }).toList();
        }

        return SafeArea(
          child: Column(
            children: [
              // Header
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
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) _searchController.clear();
                        });
                      },
                      icon: Icon(_isSearching ? Icons.close : Icons.search_outlined),
                    ),
                    IconButton(
                      onPressed: _showCreatePlaylistDialog,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              if (!_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Danh sách phát'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Nghệ sĩ'),
                    ],
                  ),
                ),

              // Sort Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.swap_vert, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      'Gần đây',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final bool isSpecial = item['isSpecial'] == true;
                    final bool isArtist = item['type'] == 'Artist';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      onTap: () {
                        if (isSpecial) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavoriteSongsScreen(controller: widget.controller),
                            ),
                          );
                        } else if (isArtist) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArtistSongsScreen(
                                artistName: item['title'],
                                controller: widget.controller,
                              ),
                            ),
                          );
                        } else {
                          // Standard Playlist
                          final songIds = widget.controller.playlists[item['id']]!;
                          final playlistSongs = demoSongs.where((s) => songIds.contains(s.id)).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlaylistDetailScreen(
                                title: item['title'],
                                songs: playlistSongs,
                                controller: widget.controller,
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
                          gradient: isSpecial && item['image'] == null
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF450AF5), Color(0xFFC4EFD9)],
                                )
                              : null,
                          shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: isArtist ? null : BorderRadius.circular(8),
                          image: item['image'] != null
                              ? DecorationImage(
                                  image: AssetImage(item['image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item['image'] == null 
                          ? Icon(
                              isSpecial
                                  ? Icons.favorite
                                  : (isArtist ? Icons.person : Icons.music_note),
                              color: Colors.white,
                              size: isSpecial ? 28 : 24,
                            )
                          : null,
                      ),
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item['subtitle'],
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1ED760) : const Color(0xFF2A2A2A),
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