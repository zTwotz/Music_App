import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/audio_player_controller.dart';
import '../../core/services/artist_service.dart';
import '../../shared/data/demo_songs.dart';
import '../../shared/models/song.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../player/full_player_screen.dart';

class ArtistSongsScreen extends StatefulWidget {
  final String artistName;
  final String? avatarUrl;
  final AudioPlayerController controller;
  final List<Song> songs;

  const ArtistSongsScreen({
    super.key,
    required this.artistName,
    this.avatarUrl,
    required this.controller,
    List<Song>? songs,
  }) : songs = songs ?? demoSongs;

  @override
  State<ArtistSongsScreen> createState() => _ArtistSongsScreenState();
}

class _ArtistSongsScreenState extends State<ArtistSongsScreen> {
  late List<Song> artistSongs;
  String? _fetchedAvatarUrl;
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _findArtistSongs();
    _fetchArtistAvatar();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final newOpacity = (offset / 150).clamp(0.0, 1.0);
      if (newOpacity != _opacity) {
        setState(() => _opacity = newOpacity);
      }
    });
  }

  Future<void> _fetchArtistAvatar() async {
    if (widget.avatarUrl != null) return;

    final artists = await ArtistService().searchArtists(widget.artistName);
    if (artists.isNotEmpty && mounted) {
      final match = artists.firstWhere(
        (a) => a.name.toLowerCase() == widget.artistName.toLowerCase(),
        orElse: () => artists.first,
      );
      setState(() {
        _fetchedAvatarUrl = match.avatarUrl;
      });
    }
  }

  void _findArtistSongs() {
    List<String> extractArtists(String artistStr) {
      final normalized = artistStr.replaceAll(
        RegExp(
          r'\s+(ft\.?|feat\.?|x|&|-)\s+|,\s*',
          caseSensitive: false,
        ),
        '|||',
      );

      return normalized
          .split('|||')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final targetArtist = widget.artistName.trim().toLowerCase();

    artistSongs = widget.songs.where((s) {
      final sourceArtists = extractArtists(s.artist);
      return sourceArtists.contains(targetArtist);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? artistImage = widget.avatarUrl ?? _fetchedAvatarUrl;
    if (artistImage == null || artistImage.isEmpty) {
      try {
        final song = artistSongs.first;
        artistImage = song.coverAsset ?? song.coverUrl;
      } catch (_) {}
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isFollowing = widget.controller.isFollowing(widget.artistName);

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Opacity(
                    opacity: _opacity,
                    child: Text(
                      widget.artistName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (artistImage != null)
                        artistImage.startsWith('http')
                            ? Image.network(artistImage, fit: BoxFit.cover)
                            : Image.asset(artistImage, fit: BoxFit.cover)
                      else
                        Container(color: Colors.grey[900]),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black54,
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.artistName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              '231.698 người nghe hằng tháng',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1ED760),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (artistSongs.isNotEmpty) {
                              widget.controller.selectSong(
                                artistSongs.first,
                                queue: artistSongs,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullPlayerScreen(
                                    controller: widget.controller,
                                    allSongs: widget.songs,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          if (artistSongs.isNotEmpty) {
                            final shuffled = List<Song>.from(artistSongs)..shuffle();
                            widget.controller.selectSong(
                              shuffled.first,
                              queue: shuffled,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullPlayerScreen(
                                  controller: widget.controller,
                                  allSongs: widget.songs,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.shuffle, color: Colors.white70),
                        iconSize: 28,
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {
                          widget.controller.toggleFollow(widget.artistName);
                          HapticFeedback.mediumImpact();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Phổ biến',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              artistSongs.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'Không có bài hát nào',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = artistSongs[index];
                          final isCurrentSong =
                              widget.controller.currentSong?.id == song.id;

                          return InkWell(
                            onTap: () {
                              widget.controller.selectSong(
                                song,
                                queue: artistSongs,
                              );
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: _buildSongCover(song),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: TextStyle(
                                            color: isCurrentSong
                                                ? Colors.green
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isCurrentSong)
                                          const Text(
                                            'Đang phát',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentSong) ...[
                                    AnimatedEqualizer(
                                      isPlaying: widget.controller.isPlaying,
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  IconButton(
                                    onPressed: () => showSongOptionsBottomSheet(
                                      context,
                                      song: song,
                                      controller: widget.controller,
                                      allSongs: widget.songs,
                                    ),
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: artistSongs.length,
                      ),
                    ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 140),
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
        errorBuilder: (_, __, ___) => Container(color: Colors.white10),
      );
    }
    if ((song.coverUrl ?? '').isNotEmpty) {
      return Image.network(
        song.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.white10),
      );
    }
    return Container(color: Colors.white10);
  }
}
