import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../features/artist/artist_songs_screen.dart';
import '../../shared/data/demo_songs.dart';
import '../models/song.dart';

void showSongOptionsBottomSheet(
  BuildContext context, {
  required Song song,
  required AudioPlayerController controller,
  List<Song>? allSongs,
}) {
  final songsSource = allSongs ?? demoSongs;

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final isFavorite = controller.favoriteSongIds.contains(song.id);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildSongCover(
                        song,
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white70,
                  ),
                  title: Text(
                    isFavorite
                        ? 'Đã thêm vào yêu thích'
                        : 'Thêm vào yêu thích',
                  ),
                  onTap: () {
                    controller.toggleFavoriteFor(song.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.playlist_add,
                    color: Colors.white70,
                  ),
                  title: const Text('Thêm vào danh sách phát'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPlaylistsBottomSheet(context, song, controller);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.album, color: Colors.white70),
                  title: const Text('Xem album'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToArtistScreen(
                      context,
                      song,
                      controller,
                      songsSource,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white70),
                  title: const Text('Xem nghệ sĩ'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAllArtistsScreen(
                      context,
                      song,
                      controller,
                      songsSource,
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _navigateToArtistScreen(
  BuildContext context,
  Song song,
  AudioPlayerController controller,
  List<Song> songs,
) {
  final mainArtist = song.artist
      .split(
        RegExp(
          r'\s+(ft|x|,|&|-)\s+|ft\.|feat\.',
          caseSensitive: false,
        ),
      )
      .first
      .trim();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ArtistSongsScreen(
        artistName: mainArtist,
        controller: controller,
        songs: songs,
      ),
    ),
  );
}

void _navigateToAllArtistsScreen(
  BuildContext context,
  Song song,
  AudioPlayerController controller,
  List<Song> songs,
) {
  final mainArtist = song.artist
      .split(
        RegExp(
          r'\s+(ft|x|&|-)\s+|ft\.|feat\.|,\s*',
          caseSensitive: false,
        ),
      )
      .first
      .trim();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ArtistSongsScreen(
        artistName: mainArtist,
        controller: controller,
        songs: songs,
      ),
    ),
  );
}

void _showPlaylistsBottomSheet(
  BuildContext context,
  Song song,
  AudioPlayerController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final playlists = controller.playlists.keys.toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thêm vào danh sách phát',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text('Tạo danh sách phát mới'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog(context, song, controller);
                  },
                ),
                const Divider(color: Colors.white10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlistName = playlists[index];
                    final songCount = controller.playlists[playlistName]!.length;

                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.queue_music,
                          color: Colors.white70,
                        ),
                      ),
                      title: Text(playlistName),
                      subtitle: Text('$songCount bài hát'),
                      onTap: () {
                        controller.addSongToPlaylist(playlistName, song.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm vào $playlistName')),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showCreatePlaylistDialog(
  BuildContext context,
  Song song,
  AudioPlayerController controller,
) {
  final textController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Tạo danh sách phát mới'),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tên danh sách phát',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
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
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                controller.createPlaylist(name);
                controller.addSongToPlaylist(name, song.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã tạo và thêm vào $name')),
                );
              }
            },
            child: const Text(
              'Tạo',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSongCover(
  Song song, {
  double? width,
  double? height,
}) {
  if ((song.coverAsset ?? '').isNotEmpty) {
    return Image.asset(
      song.coverAsset!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.white10,
        child: const Icon(Icons.music_note),
      ),
    );
  }

  if ((song.coverUrl ?? '').isNotEmpty) {
    return Image.network(
      song.coverUrl!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.white10,
        child: const Icon(Icons.music_note),
      ),
    );
  }

  return Container(
    width: width,
    height: height,
    color: Colors.white10,
    child: const Icon(Icons.music_note),
  );
}