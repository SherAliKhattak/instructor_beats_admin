import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/video_category_model.dart';
import 'package:instructor_beats_admin/services/firebase_video_category_service.dart';

class VideoCategoriesController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final FirebaseVideoCategoryService _service =
      Get.find<FirebaseVideoCategoryService>();

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 7;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      if (data.videoCategories.isEmpty) {
        await data.refreshVideoCategoriesFromFirebase();
      }
    });
  }

  List<VideoCategoryModel> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    final list = data.videoCategories.toList();
    if (q.isEmpty) return list;
    return list.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<VideoCategoryModel> get pageItems {
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

  Future<bool> addVideoCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final id = 'vc_${DateTime.now().millisecondsSinceEpoch}';
    final category = VideoCategoryModel(
      id: id,
      name: trimmed,
      createdAt: DateTime.now(),
    );

    try {
      await _service.upsertVideoCategory(category);
      data.addVideoCategory(category);
      await data.recordRecentActivity(
        'New video category',
        '“${category.name}” is ready for the Videos tab.',
        kind: 'video_category_added',
      );
      deferredSnackbar(
        'Category added',
        'Assign videos to it from the Videos tab.',
      );
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t save category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> updateVideoCategory(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    VideoCategoryModel? current;
    for (final c in data.videoCategories) {
      if (c.id == id) {
        current = c.copyWith(name: trimmed);
        break;
      }
    }
    if (current == null) return false;

    try {
      await _service.upsertVideoCategory(current);
      data.updateVideoCategory(current.id, current.name);
      await data.recordRecentActivity(
        'Video category updated',
        'Your changes to “${current.name}” were saved.',
        kind: 'video_category_updated',
      );
      deferredSnackbar(
        'Category updated',
        'The new name is saved for all videos that use it.',
      );
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  void deleteVideoCategory(String id) {
    _deleteVideoCategory(id);
  }

  Future<void> _deleteVideoCategory(String id) async {
    var label = id;
    try {
      label = data.videoCategories.firstWhere((c) => c.id == id).name;
    } catch (_) {}
    try {
      await _service.deleteVideoCategory(id);
      data.deleteVideoCategory(id);
      _clampPage();
      await data.recordRecentActivity(
        'Video category deleted',
        '“$label” was removed.',
        kind: 'video_category_deleted',
      );
      deferredSnackbar(
        'Category removed',
        'Videos that used it no longer have that label until you pick another.',
      );
    } catch (_) {
      deferredSnackbar(
        'Couldn’t delete category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
    }
  }
}
