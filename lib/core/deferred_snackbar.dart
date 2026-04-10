import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

/// Shows a snackbar after the current frame so it does not compete with a
/// closing [Navigator] route or [Dialog] overlay (common on web).
void deferredSnackbar(String title, String message) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  });
}
