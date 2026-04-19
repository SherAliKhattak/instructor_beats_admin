import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instructor_beats_admin/models/video_category_model.dart';

class FirebaseVideoCategoryService {
  FirebaseVideoCategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<VideoCategoryModel>> fetchVideoCategories() async {
    final snap = await _firestore.collection('video_categories').get();

    return snap.docs.map((doc) {
      final data = doc.data();
      final createdAtRaw = data['created_at'];
      DateTime createdAt = DateTime.now();
      if (createdAtRaw is Timestamp) {
        createdAt = createdAtRaw.toDate();
      } else if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
      }

      return VideoCategoryModel(
        id: (data['id'] as String?)?.trim().isNotEmpty == true
            ? data['id'] as String
            : doc.id,
        name: (data['name'] as String? ?? '').trim(),
        createdAt: createdAt,
      );
    }).where((c) => c.name.isNotEmpty).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> upsertVideoCategory(VideoCategoryModel category) {
    return _firestore.collection('video_categories').doc(category.id).set({
      'id': category.id,
      'name': category.name,
      'created_at': Timestamp.fromDate(category.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteVideoCategory(String id) {
    return _firestore.collection('video_categories').doc(id).delete();
  }
}
