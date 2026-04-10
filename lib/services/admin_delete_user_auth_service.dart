import 'package:cloud_functions/cloud_functions.dart';

/// Deletes another user's Firebase Auth account via a Callable Cloud Function
/// that uses the Admin SDK.
///
/// Do **not** use `currentUser.delete()` on the default app here — that only
/// removes the **signed-in** account (the admin).
class AdminDeleteUserAuthService {
  AdminDeleteUserAuthService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  static const _callableName = 'deleteUserAuth';

  /// [deleted] — Auth user removed (or already absent server-side).
  /// [skipped] — Callable missing or transient failure; caller may still drop Firestore.
  /// [blocked] — Permission / not signed in; do not remove Firestore.
  Future<AdminAuthDeleteOutcome> deleteAuthUser(String uid) async {
    try {
      final callable = _functions.httpsCallable(_callableName);
      await callable.call(<String, dynamic>{'uid': uid});
      return AdminAuthDeleteOutcome.deleted;
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'permission-denied':
        case 'unauthenticated':
        case 'invalid-argument':
          return AdminAuthDeleteOutcome.blocked;
        default:
          return AdminAuthDeleteOutcome.skipped;
      }
    } catch (_) {
      return AdminAuthDeleteOutcome.skipped;
    }
  }
}

enum AdminAuthDeleteOutcome { deleted, skipped, blocked }
