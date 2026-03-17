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