import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instructor_beats_admin/firebase_options.dart';

/// Uses a **secondary** Firebase app so `createUserWithEmailAndPassword` does not
/// sign the admin out of the primary [FirebaseAuth.instance].
class ConsumerUserAuthService {
  ConsumerUserAuthService();

  static const _appName = 'UserSignupHelper';

  FirebaseAuth? _secondaryAuth;

  Future<FirebaseAuth> _auth() async {
    if (_secondaryAuth != null) {
      return _secondaryAuth!;
    }
    final FirebaseApp app;
    if (Firebase.apps.any((a) => a.name == _appName)) {
      app = Firebase.app(_appName);
    } else {
      app = await Firebase.initializeApp(
        name: _appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _secondaryAuth = FirebaseAuth.instanceFor(app: app);
    return _secondaryAuth!;
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = await _auth();
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await auth.signOut();
    return cred;
  }

  /// Removes the Auth account if Firestore profile creation failed afterward.
  Future<void> deleteUserForRollback({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _auth();
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.delete();
      await auth.signOut();
    } catch (_) {}
  }

  static String messageForCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This way of creating accounts isn’t turned on. Ask your administrator.';
      default:
        return 'We couldn’t create the account. Please try again in a moment.';
    }
  }
}
