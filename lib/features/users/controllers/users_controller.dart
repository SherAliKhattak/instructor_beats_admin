import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/input_validation.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/app_user_model.dart';
import 'package:instructor_beats_admin/services/consumer_user_auth_service.dart';
import 'package:instructor_beats_admin/services/admin_delete_user_auth_service.dart';
import 'package:instructor_beats_admin/services/firebase_user_service.dart';

class UsersController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final FirebaseUserService _service = Get.find<FirebaseUserService>();
  final AdminDeleteUserAuthService _deleteUserAuth =
      Get.find<AdminDeleteUserAuthService>();
  final ConsumerUserAuthService _consumerAuth =
      Get.find<ConsumerUserAuthService>();

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      if (data.users.isEmpty) {
        await data.refreshUsersFromFirebase();
      }
    });
  }

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 6;

  List<AppUserModel> get filtered {
    var list = data.users.toList();
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) {
        return u.displayName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<AppUserModel> get pageItems {
    _clampPage();
    final list = filtered;
    if (list.isEmpty) return [];
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = math.min(start + itemsPerPage, list.length);
    return list.sublist(start, end);
  }

  void setSearch(String q) {
    searchQuery.value = q;
    currentPage.value = 1;
  }

  void setPage(int page) {
    _clampPage();
    currentPage.value = page.clamp(1, totalPages);
  }

  void _clampPage() {
    final tp = totalPages;
    if (currentPage.value > tp) currentPage.value = tp;
    if (currentPage.value < 1) currentPage.value = 1;
  }

  Future<void> toggleDisabled(AppUserModel user) async {
    final next = user.copyWith(disabled: !user.disabled);
    try {
      await _service.upsertUser(next);
      data.updateUser(user.id, disabled: next.disabled);
      await data.recordRecentActivity(
        'Sign-in access changed',
        next.disabled
            ? '“${user.displayName}” can no longer sign in.'
            : '“${user.displayName}” can sign in again.',
        kind: 'user_status',
      );
      deferredSnackbar(
        'Member updated',
        next.disabled
            ? 'They can’t sign in until you enable them again.'
            : 'They can sign in again with their usual email and password.',
      );
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update member',
        'Check your connection and try again. If the problem continues, contact support.',
      );
    }
  }

  Future<bool> updateDisplayName(AppUserModel user, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final next = user.copyWith(displayName: trimmed);
    try {
      await _service.upsertUser(next);
      data.updateUser(user.id, displayName: next.displayName);
      await data.recordRecentActivity(
        'Display name updated',
        '“${user.displayName}” now shows as “$trimmed”.',
        kind: 'user_updated',
      );
      deferredSnackbar(
        'Display name updated',
        'They now appear as “$trimmed” in your list and the app.',
      );
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update member',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<void> deleteUser(String id) async {
    var label = id;
    try {
      label = data.users.firstWhere((u) => u.id == id).displayName;
    } catch (_) {}

    final authOutcome = await _deleteUserAuth.deleteAuthUser(id);
    if (authOutcome == AdminAuthDeleteOutcome.blocked) {
      deferredSnackbar(
        'Couldn’t remove member',
        'You can’t remove your own account from this screen, or the server '
        'rejected the request. Try a different account or contact support.',
      );
      return;
    }

    try {
      await _service.deleteUser(id);
      data.deleteUser(id);
      setPage(1);
      await data.recordRecentActivity(
        'Member removed',
        authOutcome == AdminAuthDeleteOutcome.deleted
            ? '“$label” was fully removed and can no longer sign in.'
            : '“$label” was removed from your member list. They might still be able to sign in until their login is turned off separately.',
        kind: 'user_deleted',
      );
      if (authOutcome == AdminAuthDeleteOutcome.skipped) {
        deferredSnackbar(
          'Removed from member list',
          'This person was removed from the list. If they can still sign in, ask your developer to finish removing their account.',
        );
      } else {
        deferredSnackbar(
          'Member removed',
          'They no longer appear in your list. Their sign-in was turned off when your setup allows it.',
        );
      }
    } catch (_) {
      deferredSnackbar(
        'Couldn’t remove member',
        'Check your connection and try again. If the problem continues, contact support.',
      );
    }
  }

  Future<bool> addUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      deferredSnackbar(
        'Name needed',
        'Add the name that should appear for this person in the app.',
      );
      return false;
    }
    if (trimmedEmail.isEmpty) {
      deferredSnackbar(
        'Email needed',
        'Enter the email they’ll use to sign in.',
      );
      return false;
    }
    if (!isPlausibleEmail(trimmedEmail)) {
      deferredSnackbar(
        'Check the email',
        'That doesn’t look like a valid email address.',
      );
      return false;
    }
    if (password.length < 6) {
      deferredSnackbar(
        'Password too short',
        'Use at least 6 characters so their account stays secure.',
      );
      return false;
    }

    late final UserCredential cred;
    try {
      cred = await _consumerAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      deferredSnackbar(
        'Couldn’t create sign-in',
        ConsumerUserAuthService.messageForCode(e.code),
      );
      return false;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t create sign-in',
        'We couldn’t set up their account. Check the email isn’t already in use, then try again.',
      );
      return false;
    }

    final uid = cred.user?.uid;
    if (uid == null || uid.isEmpty) {
      deferredSnackbar(
        'Couldn’t create sign-in',
        'Something went wrong while creating the account. Please try again.',
      );
      return false;
    }

    final createdAt = cred.user?.metadata.creationTime ?? DateTime.now();
    final user = AppUserModel(
      uid: uid,
      displayName: trimmedName,
      email: trimmedEmail,
      photoUrl: '',
      provider: 'email',
      createdAt: createdAt,
      disabled: false,
    );

    try {
      await _service.upsertUser(user);
      data.addUser(user);
      await data.recordRecentActivity(
        'New member added',
        '“$trimmedName” can sign in using $trimmedEmail.',
        kind: 'user_added',
      );
      deferredSnackbar(
        'Member added',
        'They can sign in to Instructor Beats with the email and password you set.',
      );
      return true;
    } catch (_) {
      await _consumerAuth.deleteUserForRollback(
        email: trimmedEmail,
        password: password,
      );
      deferredSnackbar(
        'Couldn’t finish setup',
        'We couldn’t save their profile, so the partial account was removed. You can try adding them again.',
      );
      return false;
    }
  }
}
