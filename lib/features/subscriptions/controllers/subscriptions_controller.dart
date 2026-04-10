import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';

/// MVC: Controller — subscriptions table + Stripe-style status actions.
class SubscriptionsController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 8;

  List<SubscriptionModel> get filtered {
    var list = data.subscriptions.toList();
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) {
        return s.userLabel.toLowerCase().contains(q) ||
            s.plan.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<SubscriptionModel> get pageItems {
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

  Future<void> cancelAtPeriodEnd(SubscriptionModel sub) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    data.upsertSubscription(
      sub.copyWith(status: SubscriptionStatus.canceled),
    );
    await data.recordRecentActivity(
      'Subscription canceled',
      'Stopped billing for ${sub.userLabel} on the ${sub.plan} plan.',
      kind: 'subscription_canceled',
    );
    deferredSnackbar('Subscription canceled successfully.', '');
  }

  Future<void> resume(SubscriptionModel sub) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    data.upsertSubscription(
      sub.copyWith(status: SubscriptionStatus.active),
    );
    await data.recordRecentActivity(
      'Subscription resumed',
      '${sub.userLabel}’s ${sub.plan} plan is active again.',
      kind: 'subscription_resumed',
    );
    deferredSnackbar('Subscription resumed successfully.', '');
  }
}
