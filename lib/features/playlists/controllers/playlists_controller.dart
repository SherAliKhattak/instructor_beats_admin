import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';

class PlaylistsController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 8;

  List<PlaylistModel> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return data.playlists.toList();

    return data.playlists.where((p) {
      final name = p.name.toLowerCase();
      final description = (p.description ?? '').toLowerCase();
      return name.contains(q) || description.contains(q);
    }).toList();
  }

  int get totalPages {
    final n = filtered.length;
    if (n <= 0) return 1;
    return math.max(1, (n / itemsPerPage).ceil());
  }

  List<PlaylistModel> get pageItems {
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

  void setFeatured(String id, bool value) {
    data.setPlaylistFeatured(id, value);
    try {
      final p = data.playlists.firstWhere((e) => e.id == id);
      data.recordRecentActivity(
        value ? 'Playlist highlighted' : 'Highlight removed',
        value
            ? '“${p.name}” is now featured for listeners.'
            : '“${p.name}” is no longer featured.',
        kind: 'playlist_featured',
      );
    } catch (_) {}
  }

  void setRecommended(String id, bool value) {
    data.setPlaylistRecommended(id, value);
    try {
      final p = data.playlists.firstWhere((e) => e.id == id);
      data.recordRecentActivity(
        value ? 'Added to recommendations' : 'Removed from recommendations',
        value
            ? '“${p.name}” will be suggested to listeners.'
            : '“${p.name}” will no longer be suggested.',
        kind: 'playlist_recommended',
      );
    } catch (_) {}
  }

  void addPlaylist(PlaylistModel p) => data.addPlaylist(p);

  void replacePlaylist(String id, PlaylistModel next) =>
      data.updatePlaylist(id, next);

  void removePlaylist(String id) {
    data.deletePlaylist(id);
    _clampPage();
  }
}
