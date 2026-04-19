import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';

/// Reads and writes the `playlists` collection (admin + consumer app).
class FirebasePlaylistService {
  FirebasePlaylistService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<PlaylistModel>> fetchPlaylists() async {
    final snap = await _firestore.collection('playlists').get();
    final out = <PlaylistModel>[];
    for (final doc in snap.docs) {
      final p = _playlistFromFirestore(doc);
      if (p != null) {
        out.add(p);
      }
    }
    out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  PlaylistModel? _playlistFromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      return null;
    }
    final m = Map<String, dynamic>.from(data as Map);
    final idField = (m['id'] as String?)?.trim();
    final docId = doc.id;
    final id = (idField != null && idField.isNotEmpty) ? idField : docId;

    final name = (m['name'] as String?)?.trim() ??
        (m['title'] as String?)?.trim() ??
        '';
    if (name.isEmpty) {
      return null;
    }

    final description = (m['description'] as String?)?.trim() ??
        (m['desc'] as String?)?.trim();
    final coverImageUrl = (m['cover_image_url'] as String?)?.trim() ??
        (m['coverImageUrl'] as String?)?.trim() ??
        (m['image_url'] as String?)?.trim() ??
        (m['imageUrl'] as String?)?.trim() ??
        (m['thumbnail_url'] as String?)?.trim() ??
        (m['thumbnailUrl'] as String?)?.trim();

    final trackCount = _trackCount(m);

    final featuredRaw = m['is_featured'] ?? m['featured'] ?? m['isFeatured'];
    final recommendedRaw =
        m['is_recommended'] ?? m['recommended'] ?? m['isRecommended'];
    final isFeatured = featuredRaw is bool ? featuredRaw : false;
    final isRecommended = recommendedRaw is bool ? recommendedRaw : false;

    final createdRaw = m['created_at'] ?? m['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    }

    return PlaylistModel(
      id: id,
      name: name,
      description: description?.isEmpty == true ? null : description,
      coverImageUrl: coverImageUrl?.isEmpty == true ? null : coverImageUrl,
      trackCount: trackCount < 0 ? 0 : trackCount,
      isFeatured: isFeatured,
      isRecommended: isRecommended,
      createdAt: createdAt,
    );
  }

  int _trackCount(Map<String, dynamic> m) {
    final tc = m['track_count'] ?? m['trackCount'];
    if (tc is int) {
      return tc;
    }
    if (tc is num) {
      return tc.toInt();
    }
    for (final key in [
      'song_ids',
      'songIds',
      'songs',
      'track_ids',
      'trackIds',
      'items',
    ]) {
      final v = m[key];
      if (v is List) {
        return v.length;
      }
    }
    return 0;
  }

  Future<void> upsertPlaylist(PlaylistModel playlist) {
    return _firestore.collection('playlists').doc(playlist.id).set({
      'id': playlist.id,
      'name': playlist.name,
      'description': playlist.description,
      'cover_image_url': playlist.coverImageUrl,
      'track_count': playlist.trackCount,
      'is_featured': playlist.isFeatured,
      'is_recommended': playlist.isRecommended,
      'created_at': Timestamp.fromDate(playlist.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deletePlaylist(String id) {
    return _firestore.collection('playlists').doc(id).delete();
  }
}
