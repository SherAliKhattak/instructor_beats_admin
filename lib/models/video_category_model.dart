/// Labels for videos only — stored in Firestore `video_categories`, not `categories`.
class VideoCategoryModel {
  VideoCategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  VideoCategoryModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return VideoCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
