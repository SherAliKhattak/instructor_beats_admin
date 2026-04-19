import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/video_model.dart';
import 'package:instructor_beats_admin/services/firebase_video_service.dart';

class VideosController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final FirebaseVideoService _service = Get.find<FirebaseVideoService>();

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 8;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      final futures = <Future<void>>[];
      if (data.videos.isEmpty) {
        futures.add(data.refreshVideosFromFirebase());
      }
      if (data.videoCategories.isEmpty) {
        futures.add(data.refreshVideoCategoriesFromFirebase());
      }
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    });
  }

  List<VideoModel> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return data.videos.toList();

    return data.videos.where((v) {
      final title = v.title.toLowerCase();
      final description = (v.description ?? '').toLowerCase();
      final url = v.videoUrl.toLowerCase();
      final cat = data.videoCategoryName(v.categoryId).toLowerCase();
      return title.contains(q) ||
          description.contains(q) ||
          url.contains(q) ||
          cat.contains(q);
    }).toList();
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<VideoModel> get pageItems {
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

  Future<void> setPublished(String id, bool value) async {
    VideoModel? v;
    try {
      v = data.videos.firstWhere((e) => e.id == id);
    } catch (_) {
      return;
    }
    final next = v.copyWith(isPublished: value);
    try {
      await _service.upsertVideo(next);
      await data.refreshVideosFromFirebase();
      try {
        final refreshed = data.videos.firstWhere((e) => e.id == id);
        await data.recordRecentActivity(
          value ? 'Video published' : 'Video hidden',
          value
              ? '“${refreshed.title}” is visible in the app.'
              : '“${refreshed.title}” is no longer shown to users.',
          kind: value ? 'video_published' : 'video_unpublished',
        );
      } catch (_) {}
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update video',
        'Check your connection and try again.',
      );
    }
  }

  Future<bool> addVideo(VideoModel v) async {
    try {
      await _service.upsertVideo(v);
      await data.refreshVideosFromFirebase();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t save video',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> replaceVideo(String id, VideoModel next) async {
    try {
      await _service.upsertVideo(next);
      await data.refreshVideosFromFirebase();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update video',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> removeVideo(String id) async {
    try {
      await _service.deleteVideo(id);
      await data.refreshVideosFromFirebase();
      _clampPage();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t delete video',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }
}
