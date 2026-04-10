const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

/**
 * Callable: delete a Firebase Auth user by uid (Admin SDK).
 * Deploy: firebase deploy --only functions:deleteUserAuth
 *
 * Security: only checks that the caller is signed in. Before production,
 * require a custom claim or Firestore admin allowlist.
 */
exports.deleteUserAuth = onCall({region: "us-central1"}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const raw = request.data && request.data.uid;
  if (typeof raw !== "string" || !raw.trim()) {
    throw new HttpsError(
        "invalid-argument",
        "Field \"uid\" (non-empty string) is required.",
    );
  }

  const uid = raw.trim();
  if (uid === request.auth.uid) {
    throw new HttpsError(
        "invalid-argument",
        "Cannot delete your own account with this action.",
    );
  }

  try {
    await admin.auth().deleteUser(uid);
  } catch (e) {
    const code = e.errorInfo && e.errorInfo.code ? e.errorInfo.code : e.code;
    if (code === "auth/user-not-found") {
      return {ok: true};
    }
    logger.error("deleteUserAuth failed", {uid, err: e});
    throw new HttpsError(
        "internal",
        e.message || "Failed to delete auth user.",
    );
  }

  return {ok: true};
});
