import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final Color color;

  final String? audioAsset;
  final String? audioUrl;
  final String? localFilePath;

  final String? coverAsset;
  final String? coverUrl;

  final String? lyricsAsset;
  final String? lyricsUrl;

  final bool isAsset;
  final bool isCloud;
  final bool isDownloaded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.color,
    this.audioAsset,
    this.audioUrl,
    this.localFilePath,
    this.coverAsset,
    this.coverUrl,
    this.lyricsAsset,
    this.lyricsUrl,
    this.isAsset = false,
    this.isCloud = false,
    this.isDownloaded = false,
  });

  const Song.local({
    required String id,
    required String title,
    required String artist,
    required String audioAsset,
    required String coverAsset,
    required String lyricsAsset,
    required Color color,
  }) : this(
          id: id,
          title: title,
          artist: artist,
          color: color,
          audioAsset: audioAsset,
          coverAsset: coverAsset,
          lyricsAsset: lyricsAsset,
          isAsset: true,
        );

  const Song.cloud({
    required String id,
    required String title,
    required String artist,
    required String audioUrl,
    String? coverUrl,
    String? lyricsUrl,
    required Color color,
  }) : this(
          id: id,
          title: title,
          artist: artist,
          color: color,
          audioUrl: audioUrl,
          coverUrl: coverUrl,
          lyricsUrl: lyricsUrl,
          isCloud: true,
        );

  Song copyWith({
    String? localFilePath,
    bool? isDownloaded,
  }) {
    return Song(
      id: id,
      title: title,
      artist: artist,
      color: color,
      audioAsset: audioAsset,
      audioUrl: audioUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      coverAsset: coverAsset,
      coverUrl: coverUrl,
      lyricsAsset: lyricsAsset,
      lyricsUrl: lyricsUrl,
      isAsset: isAsset,
      isCloud: isCloud,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}

class Podcast extends Song {
  final String? avatar; // Legacy field, keeping for compatibility if needed elsewhere
  final String? channelId;
  final String? channelName;
  final String? channelAvatarUrl;
  final int subscriberCount;
  final int listenCount;

  const Podcast({
    required super.id,
    required super.title,
    required super.artist,
    this.avatar,
    this.channelId,
    this.channelName,
    this.channelAvatarUrl,
    this.subscriberCount = 0,
    this.listenCount = 0,
    required super.color,
    super.audioAsset,
    super.audioUrl,
    super.coverAsset,
    super.coverUrl,
    super.lyricsAsset,
    super.lyricsUrl,
    super.isAsset,
    super.isCloud,
  });

  const Podcast.local({
    required String id,
    required String title,
    required String artist,
    required String avatar,
    required String audioAsset,
    required String coverAsset,
    required String lyricsAsset,
    required Color color,
  }) : this(
          id: id,
          title: title,
          artist: artist,
          avatar: avatar,
          channelName: artist,
          channelAvatarUrl: avatar,
          color: color,
          audioAsset: audioAsset,
          coverAsset: coverAsset,
          lyricsAsset: lyricsAsset,
          isAsset: true,
        );

  const Podcast.cloud({
    required String id,
    required String title,
    required String artist,
    String? channelId,
    String? channelName,
    String? channelAvatarUrl,
    int subscriberCount = 0,
    int listenCount = 0,
    required String audioUrl,
    String? coverUrl,
    String? lyricsUrl,
    required Color color,
  }) : this(
          id: id,
          title: title,
          artist: artist,
          channelId: channelId,
          channelName: channelName ?? artist,
          channelAvatarUrl: channelAvatarUrl,
          subscriberCount: subscriberCount,
          listenCount: listenCount,
          color: color,
          audioUrl: audioUrl,
          coverUrl: coverUrl,
          lyricsUrl: lyricsUrl,
          isCloud: true,
        );
}