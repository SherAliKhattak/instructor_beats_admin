import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instructor_beats_admin/models/song_model.dart';

class FirebaseSongService {
  FirebaseSongService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<String> uploadImage({
    required String songId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadFile(
      folder: 'songs/images',
      songId: songId,
      bytes: bytes,
      fileName: fileName,
      contentType: _inferImageContentType(fileName),
    );
  }

  Future<String> uploadAudio({
    required String songId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return _uploadFile(
      folder: 'songs/audio',
      songId: songId,
      bytes: bytes,
      fileName: fileName,
      contentType: _inferAudioContentType(fileName),
    );
  }

  /// Loads all documents from the `songs` collection (admin panel + mobile app writes).
  Future<List<SongModel>> fetchSongs() async {
    final snap = await _firestore.collection('songs').get();
    final out = <SongModel>[];
    for (final doc in snap.docs) {
      final song = _songFromFirestore(doc);
      if (song != null) {
        out.add(song);
      }
    }
    out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  SongModel? _songFromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      return null;
    }
    final m = Map<String, dynamic>.from(data as Map);
    final id = (m['id'] as String?)?.trim();
    final docId = doc.id;
    final songId = (id != null && id.isNotEmpty) ? id : docId;
    final title = (m['title'] as String?)?.trim() ?? '';
    final artist = (m['artist'] as String?)?.trim() ?? '';
    if (title.isEmpty && artist.isEmpty) {
      return null;
    }
    final categoryId = (m['category_id'] as String?)?.trim() ??
        (m['categoryId'] as String?)?.trim() ??
        '';
    final bpm = _asInt(m['bpm'], 120);
    final durationSec = _asInt(
      m['duration_sec'] ?? m['durationSec'],
      180,
    );
    final imageUrl = (m['image_url'] as String?)?.trim() ??
        (m['imageUrl'] as String?)?.trim() ??
        '';
    final audioUrl = (m['audio_url'] as String?)?.trim() ??
        (m['audioUrl'] as String?)?.trim() ??
        '';
    final isActive = m['is_active'] ?? m['isActive'];
    final active = isActive is bool ? isActive : true;
    final createdRaw = m['created_at'] ?? m['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    }

    return SongModel(
      id: songId,
      title: title.isEmpty ? 'Untitled' : title,
      artist: artist.isEmpty ? 'Unknown' : artist,
      categoryId: categoryId,
      bpm: bpm <= 0 ? 120 : bpm,
      durationSec: durationSec < 0 ? 0 : durationSec,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      isActive: active,
      createdAt: createdAt,
    );
  }

  int _asInt(dynamic v, int fallback) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return fallback;
  }

  Future<void> upsertSong(SongModel song) {
    return _firestore.collection('songs').doc(song.id).set({
      'id': song.id,
      'title': song.title,
      'artist': song.artist,
      'category_id': song.categoryId,
      'bpm': song.bpm,
      'duration_sec': song.durationSec,
      'image_url': song.imageUrl,
      'audio_url': song.audioUrl,
      'is_active': song.isActive,
      'created_at': Timestamp.fromDate(song.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> _uploadFile({
    required String folder,
    required String songId,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final safeName = fileName.trim().isEmpty ? 'file' : fileName.trim();
    final ext = _fileExtension(safeName);
    final path = '$folder/$songId${ext.isEmpty ? '' : '.$ext'}';
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  String _fileExtension(String name) {
    final i = name.lastIndexOf('.');
    if (i <= 0 || i >= name.length - 1) return '';
    return name.substring(i + 1).toLowerCase();
  }

  String _inferImageContentType(String name) {
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

  String _inferAudioContentType(String name) {
    switch (_fileExtension(name)) {
      case 'wav':
        return 'audio/wav';
      case 'aac':
        return 'audio/aac';
      case 'm4a':
        return 'audio/mp4';
      case 'ogg':
        return 'audio/ogg';
      case 'mp3':
      default:
        return 'audio/mpeg';
    }
  }
}
