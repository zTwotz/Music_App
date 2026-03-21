class Artist {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? avatarFile;

  Artist({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.avatarFile,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      avatarFile: json['avatar_file'],
    );
  }
}
