import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/song_model.dart';

/// MVC: Controller — filters + pagination over songs.
class SongsController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      if (data.songs.isEmpty) {
        await data.refreshSongsFromFirebase();
      }
    });
  }

  final RxString searchQuery = ''.obs;
  final RxnString categoryFilterId = RxnString();
  final RxBool activeOnly = false.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 8;

  List<SongModel> get filtered {
    var list = data.songs.toList();
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) {
        return s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q);
      }).toList();
    }
    final cat = categoryFilterId.value;
    if (cat != null && cat.isNotEmpty) {
      list = list.where((s) => s.categoryId == cat).toList();
    }
    if (activeOnly.value) {
      list = list.where((s) => s.isActive).toList();
    }
    return list;
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<SongModel> get pageItems {
    clampPage();
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

  void setCategoryFilter(String? id) {
    categoryFilterId.value = id;
    currentPage.value = 1;
  }

  void setActiveOnly(bool v) {
    activeOnly.value = v;
    currentPage.value = 1;
  }

  void setPage(int page) {
    clampPage();
    final tp = totalPages;
    currentPage.value = page.clamp(1, tp);
  }

  void clampPage() {
    final tp = totalPages;
    if (currentPage.value > tp) currentPage.value = tp;
    if (currentPage.value < 1) currentPage.value = 1;
  }
}
