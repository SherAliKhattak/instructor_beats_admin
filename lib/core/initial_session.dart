import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Decides the first route before [runApp] so a restored admin session opens
/// on `/admin` without flashing `/login`.
///
/// Uses [FirebaseAuth.authStateChanges] first event so web IndexedDB restore
/// finishes before we read the user ( [currentUser] alone can be null briefly).
abstract final class InitialSession {
  static bool startAsAdminSession = false;

  static Future<void> resolve() async {
    startAsAdminSession = false;
    final user = await FirebaseAuth.instance.authStateChanges().first;
    final email = user?.email?.trim();
    if (email == null || email.isEmpty) {
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        await FirebaseAuth.instance.signOut();
        return;
      }
      startAsAdminSession = true;
    } catch (_) {
      await FirebaseAuth.instance.signOut();
    }
  }
}
