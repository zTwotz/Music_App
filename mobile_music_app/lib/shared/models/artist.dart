class Artist {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? avatarFile;
  final int monthlyListeners;

  Artist({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarFile,
    this.monthlyListeners = 0,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      avatarFile: json['avatar_file'],
      monthlyListeners: json['monthly_listeners'] ?? 0,
    );
  }
}
