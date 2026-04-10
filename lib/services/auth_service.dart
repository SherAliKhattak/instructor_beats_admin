import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Auth service: sign up and login with email/password only.
/// Throws [AuthException] with a user-friendly message on failure.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes (user or null). Used to persist login state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user, or null if not logged in. Persisted by Firebase.
  User? get currentUser => _auth.currentUser;

  /// Creates a new user with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    }
  }

  /// Sends a password reset email to [email].
  /// Throws [AuthException] on failure.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    }
  }

  /// Signs in with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFromFirebaseCode(e.code));
    }
  }

  /// Signs out the current user.
  Future<void> signOut() => _auth.signOut();

  /// Returns true if [email] exists in the `admin` collection.
  Future<bool> isAdminEmail(String email) async {
    final snap = await _db
        .collection('admin')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  static String _messageFromFirebaseCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in or use another email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Sign-in with email isn’t available. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Check for typos or use another email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Exception with a user-facing message for the error dialog.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

