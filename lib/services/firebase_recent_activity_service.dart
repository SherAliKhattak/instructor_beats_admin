import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instructor_beats_admin/models/activity_item_model.dart';

/// Firestore collection: `recent_activity`
/// Fields: `title`, `subtitle`, optional `kind`, `at` (server timestamp).
/// Add Firestore rules so authenticated admin users can read/write this collection.
class FirebaseRecentActivityService {
  FirebaseRecentActivityService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String collectionName = 'recent_activity';

  /// How many rows the admin UI loads from Firestore (newest first).
  static const int recentListLimit = 5;

  /// Appends one activity row (newest first when fetched with [fetchRecent]).
  Future<void> append({
    required String title,
    required String subtitle,
    String? kind,
  }) {
    return _firestore.collection(collectionName).add({
      'title': title,
      'subtitle': subtitle,
      if (kind != null && kind.isNotEmpty) 'kind': kind,
      'at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ActivityItemModel>> fetchRecent({
    int limit = recentListLimit,
  }) async {
    final snap = await _firestore
        .collection(collectionName)
        .orderBy('at', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      DateTime at = DateTime.now();
      final raw = data['at'];
      if (raw is Timestamp) {
        at = raw.toDate();
      }
      return ActivityItemModel(
        id: doc.id,
        title: (data['title'] as String? ?? '').trim(),
        subtitle: (data['subtitle'] as String? ?? '').trim(),
        at: at,
      );
    }).toList();
  }
}
