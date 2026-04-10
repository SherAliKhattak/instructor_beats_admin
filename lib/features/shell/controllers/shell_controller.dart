import 'package:get/get.dart';
import 'package:instructor_beats_admin/features/shell/shell_section.dart';

/// MVC: Controller — which admin section is visible inside the shell.
class ShellController extends GetxController {
  final Rx<AdminShellSection> current = AdminShellSection.dashboard.obs;

  void goTo(AdminShellSection section) {
    current.value = section;
  }
}
