import 'package:flutter/material.dart';
import 'dart:math';
import '../../shared/models/song.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../shared/widgets/animated_equalizer.dart';
import '../../shared/widgets/song_options_bottom_sheet.dart';
import '../player/full_player_screen.dart';
import '../../shared/data/demo_songs.dart';


class SearchScreen extends StatefulWidget {
  final AudioPlayerController controller;
  final List<Song> songs;

  const SearchScreen({
    super.key,
    required this.controller,
    required this.songs,
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

  late final List<Map<String, dynamic>> browseItems;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initializeBrowseItems();
  }

  void _initializeBrowseItems() {
    final random = Random();
    final songs = widget.songs;
    if (songs.isEmpty) {
      browseItems = [];
      return;
    }
    browseItems = [
      {'title': 'Nhạc', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.red[700]},
      {'title': 'Podcasts', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.pink[700]},
      {'title': 'Sự kiện trực tiếp', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.purple[700]},
      {'title': 'Dành cho bạn', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.deepPurple[700]},
      {'title': 'Bản phát hành mới', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.indigo[700]},
      {'title': 'Mới phát hành', 'image': songs[random.nextInt(songs.length)].coverAsset, 'color': Colors.blue[700]},
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
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredSongs = [];
      });
    } else {
      setState(() {
        _isSearching = true;
        _filteredSongs = widget.songs.where((song) {
          return song.title.toLowerCase().contains(query) ||
                 song.artist.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _handleTagSelection(String tag) {
    _searchController.text = tag;
    _searchFocusNode.unfocus();
    _showRandomSongs();
  }

  void _showRandomSongs() {
    final random = Random();
    final List<Song> randomSongs = List<Song>.from(widget.songs)..shuffle(random);
    setState(() {
      _isSearching = true;
      _filteredSongs = randomSongs.take(15).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            children: [
              // Header with User Icon
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
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Bạn muốn nghe gì?',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black87),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              if (!_isSearching) ...[
                // Explore Tags
                const Text(
                  'Khám phá nội dung mới mẻ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF262626),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            exploreTags[index],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Browse All
                const Text(
                  'Duyệt tìm tất cả',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: browseItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final item = browseItems[index];
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = item['title'];
                        _searchFocusNode.unfocus();
                        _showRandomSongs();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(item['image']),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
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
                              item['title'],
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
                      ),
                    );
                  },
                ),
              ] else ...[
                // Search Results
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kết quả tìm kiếm',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                      child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
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
                    final isCurrentSong = widget.controller.currentSong?.id == song.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        widget.controller.selectSong(song, queue: _filteredSongs);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullPlayerScreen(
                              controller: widget.controller,
                            ),
                          ),
                        );
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          song.coverAsset,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          color: isCurrentSong ? Colors.green : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(song.artist, style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrentSong)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: AnimatedEqualizer(isPlaying: widget.controller.isPlaying),
                            ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => showSongOptionsBottomSheet(
                              context,
                              song: song,
                              controller: widget.controller,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        );
      },
    );
  }
}