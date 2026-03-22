import 'package:flutter/material.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../core/navigation/player_navigator.dart';
import '../../core/services/podcast_service.dart';
import '../../shared/models/song.dart';
import '../home/home_screen.dart';

class ChannelScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  final String? avatarUrl;
  final int initialSubscribers;
  final AudioPlayerController controller;
  final List<Song> allSongs; // To pass to player

  const ChannelScreen({
    super.key,
    required this.channelId,
    required this.channelName,
    this.avatarUrl,
    required this.initialSubscribers,
    required this.controller,
    required this.allSongs,
  });

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final PodcastService _podcastService = PodcastService();
  List<Podcast> _channelPodcasts = [];
  bool _isLoading = true;
  bool _isSubscribed = false;
  late int _subscriberCount;

  @override
  void initState() {
    super.initState();
    _subscriberCount = widget.initialSubscribers;
    _loadChannelData();
  }

  Future<void> _loadChannelData() async {
    try {
      final all = await _podcastService.fetchCloudPodcasts();
      final filtered = all.where((p) => p.channelId == widget.channelId).toList();
      final subscribed = await _podcastService.isSubscribed(widget.channelId);

      if (mounted) {
        setState(() {
          _channelPodcasts = filtered;
          _isSubscribed = subscribed;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load channel podcasts error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSubscribe() async {
    final originalStatus = _isSubscribed;
    setState(() {
      _isSubscribed = !originalStatus;
      _subscriberCount += originalStatus ? -1 : 1;
    });

    try {
      if (originalStatus) {
        await _podcastService.unsubscribeChannel(widget.channelId);
      } else {
        await _podcastService.subscribeChannel(widget.channelId);
      }
    } catch (e) {
      debugPrint('Toggle subscribe error: $e');
      // Rollback on error
      if (mounted) {
        setState(() {
          _isSubscribed = originalStatus;
          _subscriberCount += originalStatus ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.avatarUrl != null)
                    Image.network(widget.avatarUrl!, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white10,
                    backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
                    child: widget.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.channelName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_subscriberCount người đăng ký',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubscribed ? Colors.white10 : Colors.white,
                      foregroundColor: _isSubscribed ? Colors.white : Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text(_isSubscribed ? 'Đã đăng ký' : 'Đăng ký'),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tất cả nội dung',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_channelPodcasts.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('Chưa có podcast nào')))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = _channelPodcasts[index];
                    return _buildPodcastListItem(p);
                  },
                  childCount: _channelPodcasts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildPodcastListItem(Podcast podcast) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      onTap: () async {
        await _podcastService.recordListen(podcast.id);
        widget.controller.selectSong(podcast, queue: _channelPodcasts);
        if (mounted) {
          pushFullPlayer(
            context,
            controller: widget.controller,
            allSongs: widget.allSongs,
          );
        }
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: podcast.coverUrl != null
              ? Image.network(podcast.coverUrl!, fit: BoxFit.cover)
              : const Icon(Icons.music_note),
        ),
      ),
      title: Text(
        podcast.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${podcast.listenCount} lượt nghe',
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
      trailing: const Icon(Icons.more_vert),
    );
  }
}
