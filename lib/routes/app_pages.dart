import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/middleware/auth_middleware.dart';
import 'package:instructor_beats_admin/features/auth/views/login_view.dart';
import 'package:instructor_beats_admin/features/shell/bindings/shell_binding.dart';
import 'package:instructor_beats_admin/features/shell/views/admin_shell_view.dart';
import 'package:instructor_beats_admin/routes/app_routes.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage<void>(
      name: AppRoutes.login,
      page: LoginView.new,
    ),
    GetPage<void>(
      name: AppRoutes.admin,
      page: AdminShellView.new,
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
