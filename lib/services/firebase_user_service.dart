import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instructor_beats_admin/models/app_user_model.dart';

class FirebaseUserService {
  FirebaseUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// New Firestore document id (use as `uid` field for admin-created users).
  String newUid() => _firestore.collection('users').doc().id;

  /// App users collection — shape matches consumer profiles:
  /// `uid`, `email`, `display_name`, `photo_url`, `provider`, `created_at`, `updated_at`
  /// plus optional `disabled` for this admin app.
  Future<List<AppUserModel>> fetchUsers() async {
    final snap = await _firestore.collection('users').get();
    final out = <AppUserModel>[];
    for (final doc in snap.docs) {
      final u = _userFromFirestore(doc);
      if (u != null) {
        out.add(u);
      }
    }
    out.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return out;
  }

  AppUserModel? _userFromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      return null;
    }
    final m = Map<String, dynamic>.from(data as Map);
    final uid = (m['uid'] as String?)?.trim();
    final docId = doc.id;
    final userUid = (uid != null && uid.isNotEmpty) ? uid : docId;
    final email = (m['email'] as String?)?.trim() ?? '';
    final displayName = (m['display_name'] as String?)?.trim() ??
        (m['displayName'] as String?)?.trim() ??
        '';
    final photoUrl = (m['photo_url'] as String?)?.trim() ??
        (m['photoUrl'] as String?)?.trim() ??
        '';
    final provider = (m['provider'] as String?)?.trim() ?? 'email';
    if (email.isEmpty) {
      return null;
    }
    final disabledRaw = m['disabled'];
    final disabled = disabledRaw is bool ? disabledRaw : false;
    final createdRaw = m['created_at'] ?? m['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    }

    return AppUserModel(
      uid: userUid,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      provider: provider,
      createdAt: createdAt,
      disabled: disabled,
    );
  }

  Future<void> upsertUser(AppUserModel user) {
    return _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'provider': user.provider,
        'created_at': Timestamp.fromDate(user.createdAt),
        'updated_at': FieldValue.serverTimestamp(),
        'disabled': user.disabled,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteUser(String uid) {
    return _firestore.collection('users').doc(uid).delete();
  }
}
