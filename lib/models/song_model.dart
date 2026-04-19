class SongModel {
  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.categoryIds,
    this.playlistIds = const [],
    required this.bpm,
    required this.imageUrl,
    required this.audioUrl,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String artist;
  /// One or more song category document ids.
  final List<String> categoryIds;
  /// Playlist document ids this track belongs to (admin-side assignment).
  final List<String> playlistIds;
  final int bpm;
  final String imageUrl;
  final String audioUrl;
  final bool isActive;
  final DateTime createdAt;

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    List<String>? categoryIds,
    List<String>? playlistIds,
    int? bpm,
    String? imageUrl,
    String? audioUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      categoryIds: categoryIds ?? this.categoryIds,
      playlistIds: playlistIds ?? this.playlistIds,
      bpm: bpm ?? this.bpm,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
