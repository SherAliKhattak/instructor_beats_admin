import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/features/auth/controllers/auth_controller.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';

/// Protects authenticated routes (GetX).
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    final public = route == AppRoutes.login;

    if (!auth.isLoggedIn.value && !public) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (auth.isLoggedIn.value && route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.admin);
    }
    return null;
  }
}
