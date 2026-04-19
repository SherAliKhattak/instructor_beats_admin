class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSec,
    this.categoryId,
    required this.isPublished,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSec;
  /// Firestore `video_categories` document id (not song [categories]).
  final String? categoryId;
  final bool isPublished;
  final DateTime createdAt;

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSec,
    String? categoryId,
    bool clearCategoryId = false,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSec: durationSec ?? this.durationSec,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
