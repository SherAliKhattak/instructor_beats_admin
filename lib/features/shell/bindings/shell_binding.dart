import 'package:get/get.dart';
import 'package:instructor_beats_admin/features/categories/controllers/categories_controller.dart';
import 'package:instructor_beats_admin/features/playlists/controllers/playlists_controller.dart';
import 'package:instructor_beats_admin/features/dashboard/controllers/dashboard_controller.dart';
import 'package:instructor_beats_admin/features/shell/controllers/shell_controller.dart';
import 'package:instructor_beats_admin/features/songs/controllers/songs_controller.dart';
import 'package:instructor_beats_admin/features/subscriptions/controllers/subscriptions_controller.dart';
import 'package:instructor_beats_admin/features/users/controllers/users_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ShellController.new, fenix: true);
    Get.lazyPut(DashboardController.new, fenix: true);
    Get.lazyPut(SongsController.new, fenix: true);
    Get.lazyPut(PlaylistsController.new, fenix: true);
    Get.lazyPut(CategoriesController.new, fenix: true);
    Get.lazyPut(UsersController.new, fenix: true);
    Get.lazyPut(SubscriptionsController.new, fenix: true);
  }
}
