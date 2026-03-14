import 'package:flutter/material.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String audioAsset;
  final String coverAsset;
  final String lyricsAsset;
  final Color color;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioAsset,
    required this.coverAsset,
    required this.lyricsAsset,
    required this.color,
  });
}