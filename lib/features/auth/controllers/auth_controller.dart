import 'dart:developer';

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/categories/controllers/categories_controller.dart';
import 'package:instructor_beats_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:instructor_beats_admin/features/shell/controllers/shell_controller.dart';
import 'package:instructor_beats_admin/features/songs/controllers/songs_controller.dart';
import 'package:instructor_beats_admin/features/subscriptions/controllers/subscriptions_controller.dart';
import 'package:instructor_beats_admin/features/users/controllers/users_controller.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';
import 'package:instructor_beats_admin/services/auth_service.dart';

/// MVC: Controller — auth session backed by Firebase Auth.
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoggedIn = false.obs;
  final RxBool isBusy = false.obs;

  Future<void> login({required String email, required String password}) async {
    isBusy.value = true;
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        showAppSnackbar(
          'Almost there',
          'Please enter both your email and password.',
        );
        return;
      }

      final cred = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      final ok = user != null && user.email != null
          ? await _authService.isAdminEmail(user.email!)
          : false;

      if (!ok) {
        await _authService.signOut();
        showAppSnackbar(
          'Not authorized',
          'This email isn’t set up for the admin panel. Use an approved admin account or ask your team for access.',
        );
        return;
      }

      isLoggedIn.value = true;
      final data = Get.find<AdminDataController>();
      await data.refreshCategoriesFromFirebase();
      await data.refreshSongsFromFirebase();
      await data.refreshUsersFromFirebase();
      await data.refreshActivityFromFirebase();
      Get.offAllNamed(AppRoutes.admin);
    } on AuthException catch (e) {
      final detail = e.message.trim();
      showAppSnackbar(
        'Couldn’t sign in',
        detail.isEmpty
            ? 'Double-check your email and password, then try again.'
            : detail,
      );
    } catch (e) {
      log(e.toString());
      showAppSnackbar(
        'Couldn’t sign in',
        'Something went wrong. Check your connection and try again.',
      );
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    try {
      await _authService.signOut();
    } catch (_) {
      // Even if sign-out fails remotely, clear local shell state.
    }
    _disposeShellControllers();
    Get.offAllNamed(AppRoutes.login);
  }

  void _disposeShellControllers() {
    if (Get.isRegistered<ShellController>()) {
      Get.delete<ShellController>(force: true);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }
    if (Get.isRegistered<SongsController>()) {
      Get.delete<SongsController>(force: true);
    }
    if (Get.isRegistered<CategoriesController>()) {
      Get.delete<CategoriesController>(force: true);
    }
    if (Get.isRegistered<UsersController>()) {
      Get.delete<UsersController>(force: true);
    }
    if (Get.isRegistered<SubscriptionsController>()) {
      Get.delete<SubscriptionsController>(force: true);
    }
  }
}
