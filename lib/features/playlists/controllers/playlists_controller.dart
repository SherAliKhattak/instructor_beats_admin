import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';
import 'package:instructor_beats_admin/services/firebase_playlist_service.dart';
import 'package:instructor_beats_admin/services/firebase_song_service.dart';

class PlaylistsController extends GetxController {
  final AdminDataController data = Get.find<AdminDataController>();
  final FirebasePlaylistService _service = Get.find<FirebasePlaylistService>();
  final FirebaseSongService _songService = Get.find<FirebaseSongService>();

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 8;

  @override
  void onInit() {
    super.onInit();
    Future<void>.microtask(() async {
      if (data.playlists.isEmpty) {
        await data.refreshPlaylistsFromFirebase();
      }
    });
  }

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

  Future<void> setFeatured(String id, bool value) async {
    PlaylistModel? p;
    try {
      p = data.playlists.firstWhere((e) => e.id == id);
    } catch (_) {
      return;
    }
    final next = p.copyWith(isFeatured: value);
    try {
      await _service.upsertPlaylist(next);
      await data.refreshPlaylistsFromFirebase();
      try {
        final refreshed = data.playlists.firstWhere((e) => e.id == id);
        await data.recordRecentActivity(
          value ? 'Playlist highlighted' : 'Highlight removed',
          value
              ? '“${refreshed.name}” is now featured for listeners.'
              : '“${refreshed.name}” is no longer featured.',
          kind: 'playlist_featured',
        );
      } catch (_) {}
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update playlist',
        'Check your connection and try again.',
      );
    }
  }

  Future<void> setRecommended(String id, bool value) async {
    PlaylistModel? p;
    try {
      p = data.playlists.firstWhere((e) => e.id == id);
    } catch (_) {
      return;
    }
    final next = p.copyWith(isRecommended: value);
    try {
      await _service.upsertPlaylist(next);
      await data.refreshPlaylistsFromFirebase();
      try {
        final refreshed = data.playlists.firstWhere((e) => e.id == id);
        await data.recordRecentActivity(
          value ? 'Added to recommendations' : 'Removed from recommendations',
          value
              ? '“${refreshed.name}” will be suggested to listeners.'
              : '“${refreshed.name}” will no longer be suggested.',
          kind: 'playlist_recommended',
        );
      } catch (_) {}
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update playlist',
        'Check your connection and try again.',
      );
    }
  }

  Future<bool> addPlaylist(PlaylistModel p) async {
    try {
      await _service.upsertPlaylist(p);
      await data.refreshPlaylistsFromFirebase();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t save playlist',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> replacePlaylist(String id, PlaylistModel next) async {
    try {
      await _service.upsertPlaylist(next);
      await data.refreshPlaylistsFromFirebase();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update playlist',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }

  Future<bool> updatePlaylistSongs({
    required PlaylistModel playlist,
    required List<String> songIds,
  }) async {
    final next = playlist.copyWith(
      songIds: List<String>.from(songIds),
      trackCount: songIds.length,
    );
    try {
      await _service.upsertPlaylist(next);
      await _songService.syncPlaylistMembershipOnSongs(
        playlistId: playlist.id,
        songIdsInPlaylist: songIds.toSet(),
      );
      await data.refreshPlaylistsFromFirebase();
      await data.refreshSongsFromFirebase();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t update playlist songs',
        'Check your connection and try again.',
      );
      return false;
    }
  }

  Future<bool> removePlaylist(String id) async {
    try {
      await _songService.syncPlaylistMembershipOnSongs(
        playlistId: id,
        songIdsInPlaylist: {},
      );
      await _service.deletePlaylist(id);
      await data.refreshPlaylistsFromFirebase();
      await data.refreshSongsFromFirebase();
      _clampPage();
      return true;
    } catch (_) {
      deferredSnackbar(
        'Couldn’t delete playlist',
        'Check your connection and try again. If the problem continues, contact support.',
      );
      return false;
    }
  }
}
