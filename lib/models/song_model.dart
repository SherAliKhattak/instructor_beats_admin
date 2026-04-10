class SongModel {
  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.categoryId,
    required this.bpm,
    required this.durationSec,
    required this.imageUrl,
    required this.audioUrl,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String artist;
  final String categoryId;
  final int bpm;
  final int durationSec;
  final String imageUrl;
  final String audioUrl;
  final bool isActive;
  final DateTime createdAt;

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? categoryId,
    int? bpm,
    int? durationSec,
    String? imageUrl,
    String? audioUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      categoryId: categoryId ?? this.categoryId,
      bpm: bpm ?? this.bpm,
      durationSec: durationSec ?? this.durationSec,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
