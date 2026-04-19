class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    List<String>? songIds,
    required this.trackCount,
    required this.isFeatured,
    required this.isRecommended,
    required this.createdAt,
  }) : _songIds = songIds;

  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  /// Song document ids in playlist order (mirrors `song_ids` in Firestore).
  final List<String>? _songIds;
  List<String> get songIds => _songIds ?? const [];
  final int trackCount;
  final bool isFeatured;
  final bool isRecommended;
  final DateTime createdAt;

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    List<String>? songIds,
    int? trackCount,
    bool? isFeatured,
    bool? isRecommended,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      songIds: songIds ?? this.songIds,
      trackCount: trackCount ?? this.trackCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
