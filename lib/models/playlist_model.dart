class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.trackCount,
    required this.isFeatured,
    required this.isRecommended,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final int trackCount;
  final bool isFeatured;
  final bool isRecommended;
  final DateTime createdAt;

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
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
      trackCount: trackCount ?? this.trackCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
