import 'package:get/get.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/activity_item_model.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';

/// MVC: Controller — dashboard metrics derived from [AdminDataController].
class DashboardController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      if (data.activity.isEmpty) {
        await data.refreshActivityFromFirebase();
      }
    });
  }

  final RxString activitySearchQuery = ''.obs;

  void setActivitySearch(String q) {
    activitySearchQuery.value = q;
  }

  List<ActivityItemModel> get filteredActivity {
    final q = activitySearchQuery.value.trim().toLowerCase();
    final list = data.activity.toList();
    if (q.isEmpty) return list;
    return list
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  int get songCount => data.songs.length;
  int get categoryCount => data.categories.length;
  int get userCount => data.users.length;
  int get activeSubscriptionCount => data.subscriptions
      .where((s) => s.status == SubscriptionStatus.active)
      .length;
}
