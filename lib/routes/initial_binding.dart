import 'package:get/get.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/data/admin_repository.dart';
import 'package:instructor_beats_admin/features/auth/controllers/auth_controller.dart';
import 'package:instructor_beats_admin/services/auth_service.dart';
import 'package:instructor_beats_admin/services/firebase_category_service.dart';
import 'package:instructor_beats_admin/services/firebase_playlist_service.dart';
import 'package:instructor_beats_admin/services/firebase_video_category_service.dart';
import 'package:instructor_beats_admin/services/firebase_video_service.dart';
import 'package:instructor_beats_admin/services/firebase_song_service.dart';
import 'package:instructor_beats_admin/services/consumer_user_auth_service.dart';
import 'package:instructor_beats_admin/services/firebase_user_service.dart';
import 'package:instructor_beats_admin/services/firebase_recent_activity_service.dart';
import 'package:instructor_beats_admin/services/admin_delete_user_auth_service.dart';

/// Global singletons for repository, Firebase services, and auth.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminRepository(), permanent: true);
    Get.put(FirebaseCategoryService(), permanent: true);
    Get.put(FirebasePlaylistService(), permanent: true);
    Get.put(FirebaseVideoCategoryService(), permanent: true);
    Get.put(FirebaseVideoService(), permanent: true);
    Get.put(FirebaseSongService(), permanent: true);
    Get.put(FirebaseUserService(), permanent: true);
    Get.put(AdminDeleteUserAuthService(), permanent: true);
    Get.put(FirebaseRecentActivityService(), permanent: true);
    Get.put(ConsumerUserAuthService(), permanent: true);
    Get.put(AdminDataController(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(AuthController(), permanent: true); // auth stream must survive route changes
  }
}
