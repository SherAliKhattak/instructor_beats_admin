import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instructor_beats_admin/core/image_url.dart';
import 'package:instructor_beats_admin/models/video_model.dart';

/// Reads and writes the `videos` collection; uploads binaries under `videos/` in Storage.
class FirebaseVideoService {
  FirebaseVideoService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Uploads a video file to `videos/files/{videoId}.{ext}`.
  Future<String> uploadVideoFile({
    required String videoId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadBytes(
      folder: 'videos/files',
      entityId: videoId,
      bytes: bytes,
      fileName: fileName,
      contentType: _inferVideoContentType(fileName),
    );
  }

  /// Uploads a poster image to `videos/thumbnails/{videoId}.{ext}`.
  Future<String> uploadThumbnail({
    required String videoId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadBytes(
      folder: 'videos/thumbnails',
      entityId: videoId,
      bytes: bytes,
      fileName: fileName,
      contentType: _inferImageContentType(fileName),
    );
  }

  Future<String> _uploadBytes({
    required String folder,
    required String entityId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final safeName = fileName.trim().isEmpty ? 'file' : fileName.trim();
    final ext = _fileExtension(safeName);
    final path = '$folder/$entityId${ext.isEmpty ? '' : '.$ext'}';
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  static String _fileExtension(String name) {
    final i = name.lastIndexOf('.');
    if (i <= 0 || i >= name.length - 1) return '';
    return name.substring(i + 1).toLowerCase();
  }

  static String _inferImageContentType(String name) {
    switch (_fileExtension(name)) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  static String _inferVideoContentType(String name) {
    switch (_fileExtension(name)) {
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'mkv':
        return 'video/x-matroska';
      case 'avi':
        return 'video/x-msvideo';
      case 'mp4':
      default:
        return 'video/mp4';
    }
  }

  static String? _asNonEmptyString(dynamic v) {
    if (v is String) {
      final t = v.trim();
      return t.isEmpty ? null : t;
    }
    return null;
  }

  /// Resolves thumbnail / poster URL from common Firestore shapes.
  static String? _parseThumbnailUrl(Map<String, dynamic> m) {
    final directKeys = <String>[
      'thumbnail_url',
      'thumbnailUrl',
      'poster_url',
      'posterUrl',
      'image_url',
      'imageUrl',
      'cover_image_url',
      'coverImageUrl',
      'thumb_url',
      'thumbUrl',
      'thumbnail_image_url',
      'thumbnail_image',
      'photo_url',
      'photoUrl',
    ];
    for (final k in directKeys) {
      final s = _asNonEmptyString(m[k]);
      if (s != null) return s;
    }

    for (final key in ['thumbnail', 'thumb', 'poster', 'cover']) {
      final raw = m[key];
      if (raw is Map) {
        final nested = Map<String, dynamic>.from(raw);
        for (final nk in [
          'url',
          'downloadUrl',
          'download_url',
          'src',
          'imageUrl',
          'image_url',
        ]) {
          final s = _asNonEmptyString(nested[nk]);
          if (s != null) return s;
        }
      }
    }
    return null;
  }

  Future<List<VideoModel>> fetchVideos() async {
    final snap = await _firestore.collection('videos').get();
    final out = <VideoModel>[];
    for (final doc in snap.docs) {
      final v = _videoFromFirestore(doc);
      if (v != null) {
        out.add(v);
      }
    }
    out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  VideoModel? _videoFromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      return null;
    }
    final m = Map<String, dynamic>.from(data as Map);
    final idField = (m['id'] as String?)?.trim();
    final docId = doc.id;
    final id = (idField != null && idField.isNotEmpty) ? idField : docId;

    final title = (m['title'] as String?)?.trim() ??
        (m['name'] as String?)?.trim() ??
        '';
    if (title.isEmpty) {
      return null;
    }

    final videoUrl = (m['video_url'] as String?)?.trim() ??
        (m['videoUrl'] as String?)?.trim() ??
        (m['url'] as String?)?.trim() ??
        (m['playback_url'] as String?)?.trim() ??
        (m['stream_url'] as String?)?.trim() ??
        (m['source_url'] as String?)?.trim() ??
        '';
    if (videoUrl.isEmpty) {
      return null;
    }

    final description = (m['description'] as String?)?.trim();
    final thumbnailUrl = _parseThumbnailUrl(m);

    final durationRaw = m['duration_sec'] ?? m['durationSec'] ?? m['duration'];
    int? durationSec;
    if (durationRaw is int) {
      durationSec = durationRaw >= 0 ? durationRaw : null;
    } else if (durationRaw is num) {
      final d = durationRaw.toInt();
      durationSec = d >= 0 ? d : null;
    }

    final pubRaw = m['is_published'] ?? m['isPublished'] ?? m['published'];
    final isPublished = pubRaw is bool ? pubRaw : true;

    final categoryId = (m['category_id'] as String?)?.trim() ??
        (m['categoryId'] as String?)?.trim() ??
        (m['video_category_id'] as String?)?.trim();
    final categoryIdNorm =
        (categoryId != null && categoryId.isNotEmpty) ? categoryId : null;

    final createdRaw = m['created_at'] ?? m['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    }

    final thumbNorm = thumbnailUrl == null || thumbnailUrl.isEmpty
        ? null
        : normalizeImageUrl(thumbnailUrl);

    return VideoModel(
      id: id,
      title: title,
      description: description?.isEmpty == true ? null : description,
      videoUrl: videoUrl,
      thumbnailUrl: thumbNorm?.isEmpty == true ? null : thumbNorm,
      durationSec: durationSec,
      categoryId: categoryIdNorm,
      isPublished: isPublished,
      createdAt: createdAt,
    );
  }

  Future<void> upsertVideo(VideoModel video) {
    return _firestore.collection('videos').doc(video.id).set({
      'id': video.id,
      'title': video.title,
      'description': video.description,
      'video_url': video.videoUrl,
      'thumbnail_url': video.thumbnailUrl,
      'duration_sec': video.durationSec,
      'category_id': video.categoryId,
      'is_published': video.isPublished,
      'created_at': Timestamp.fromDate(video.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteVideo(String id) {
    return _firestore.collection('videos').doc(id).delete();
  }
}
