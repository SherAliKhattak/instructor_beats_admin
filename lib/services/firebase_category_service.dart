import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instructor_beats_admin/models/category_model.dart';

class FirebaseCategoryService {
  FirebaseCategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<CategoryModel>> fetchCategories() async {
    final snap = await _firestore.collection('categories').get();

    return snap.docs.map((doc) {
      final data = doc.data();
      final createdAtRaw = data['created_at'];
      DateTime createdAt = DateTime.now();
      if (createdAtRaw is Timestamp) {
        createdAt = createdAtRaw.toDate();
      } else if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
      }

      return CategoryModel(
        id: (data['id'] as String?)?.trim().isNotEmpty == true
            ? data['id'] as String
            : doc.id,
        name: (data['name'] as String? ?? '').trim(),
        createdAt: createdAt,
      );
    }).where((c) => c.name.isNotEmpty).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> upsertCategory(CategoryModel category) {
    return _firestore.collection('categories').doc(category.id).set({
      'id': category.id,
      'name': category.name,
      'created_at': Timestamp.fromDate(category.createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) {
    return _firestore.collection('categories').doc(id).delete();
  }
}
