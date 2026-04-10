import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

/// User-facing snackbar: always shows a [title] and a short [message].
void showAppSnackbar(String title, String message) {
  final t = title.trim().isEmpty ? 'Notice' : title.trim();
  final m = message.trim().isEmpty
      ? 'You’re all set. If something looks wrong, try the action again.'
      : message.trim();
  Get.snackbar(
    t,
    m,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: 10,
    duration: const Duration(seconds: 4),
  );
}

/// Shows [showAppSnackbar] after the current frame (after dialogs/sheets close).
void deferredSnackbar(String title, String message) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    showAppSnackbar(title, message);
  });
}
