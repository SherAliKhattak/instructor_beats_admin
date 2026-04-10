import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/category_model.dart';
import 'package:instructor_beats_admin/services/firebase_category_service.dart';

/// MVC: Controller — category CRUD delegates to [AdminDataController].
class CategoriesController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final FirebaseCategoryService _service = Get.find<FirebaseCategoryService>();

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 7;

  List<CategoryModel> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    final list = data.categories.toList();
    if (q.isEmpty) return list;
    return list.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<CategoryModel> get pageItems {
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

  Future<bool> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final id = 'c_${DateTime.now().millisecondsSinceEpoch}';
    final category = CategoryModel(
      id: id,
      name: trimmed,
      createdAt: DateTime.now(),
    );

    try {
      await _service.upsertCategory(category);
      data.addCategory(category);
      await data.recordRecentActivity(
        'New category',
        '“${category.name}” is ready to use when you organize songs.',
        kind: 'category_added',
      );
      deferredSnackbar('Category added successfully.', '');
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t save category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> updateCategory(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    CategoryModel? current;
    for (final c in data.categories) {
      if (c.id == id) {
        current = c.copyWith(name: trimmed);
        break;
      }
    }
    if (current == null) return false;

    try {
      await _service.upsertCategory(current);
      data.updateCategory(current.id, current.name);
      await data.recordRecentActivity(
        'Category updated',
        'Your changes to “${current.name}” were saved.',
        kind: 'category_updated',
      );
      deferredSnackbar('Category updated successfully.', '');
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  void deleteCategory(String id) {
    _deleteCategory(id);
  }

  Future<void> _deleteCategory(String id) async {
    var label = id;
    try {
      label = data.categories.firstWhere((c) => c.id == id).name;
    } catch (_) {}
    try {
      await _service.deleteCategory(id);
      data.deleteCategory(id);
      _clampPage();
      await data.recordRecentActivity(
        'Category deleted',
        '“$label” was removed from your categories.',
        kind: 'category_deleted',
      );
      deferredSnackbar('Category deleted successfully.', '');
    } catch (_) {
      deferredSnackbar(
        'Couldn’t delete category',
        'Check your connection and try again. If the problem continues, contact support.',
      );
    }
  }
}
