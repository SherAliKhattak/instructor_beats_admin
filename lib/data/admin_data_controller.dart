import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_repository.dart';
import 'package:instructor_beats_admin/services/firebase_category_service.dart';
import 'package:instructor_beats_admin/services/firebase_song_service.dart';
import 'package:instructor_beats_admin/services/firebase_user_service.dart';
import 'package:instructor_beats_admin/services/firebase_playlist_service.dart';
import 'package:instructor_beats_admin/services/firebase_recent_activity_service.dart';
import 'package:instructor_beats_admin/models/activity_item_model.dart';
import 'package:instructor_beats_admin/models/app_user_model.dart';
import 'package:instructor_beats_admin/models/category_model.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';
import 'package:instructor_beats_admin/models/video_category_model.dart';
import 'package:instructor_beats_admin/models/video_model.dart';
import 'package:instructor_beats_admin/services/firebase_video_category_service.dart';
import 'package:instructor_beats_admin/services/firebase_video_service.dart';

/// MVC: Controller — exposes reactive copies of repository data for views.
class AdminDataController extends GetxController {
  final AdminRepository _repo = Get.find<AdminRepository>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<SongModel> songs = <SongModel>[].obs;
  final RxList<AppUserModel> users = <AppUserModel>[].obs;
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxList<ActivityItemModel> activity = <ActivityItemModel>[].obs;
  final RxList<PlaylistModel> playlists = <PlaylistModel>[].obs;
  final RxList<VideoModel> videos = <VideoModel>[].obs;
  final RxList<VideoCategoryModel> videoCategories = <VideoCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  /// Replaces in-memory categories with the `categories` collection in Firestore.
  Future<void> refreshCategoriesFromFirebase() async {
    try {
      final remote = await Get.find<FirebaseCategoryService>().fetchCategories();
      setCategories(remote);
    } catch (_) {
      showAppSnackbar(
        'Categories didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  /// Replaces in-memory songs with the `songs` collection in Firestore.
  Future<void> refreshSongsFromFirebase() async {
    try {
      final remote = await Get.find<FirebaseSongService>().fetchSongs();
      setSongs(remote);
    } catch (_) {
      showAppSnackbar(
        'Songs didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  /// Replaces in-memory users with the `users` collection in Firestore.
  Future<void> refreshUsersFromFirebase() async {
    try {
      final remote = await Get.find<FirebaseUserService>().fetchUsers();
      setUsers(remote);
    } catch (_) {
      showAppSnackbar(
        'Members didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  /// Replaces in-memory playlists with the `playlists` collection in Firestore.
  Future<void> refreshPlaylistsFromFirebase() async {
    try {
      final remote = await Get.find<FirebasePlaylistService>().fetchPlaylists();
      setPlaylists(remote);
    } catch (_) {
      showAppSnackbar(
        'Playlists didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  /// Replaces in-memory videos with the `videos` collection in Firestore.
  Future<void> refreshVideosFromFirebase() async {
    try {
      final remote = await Get.find<FirebaseVideoService>().fetchVideos();
      setVideos(remote);
    } catch (_) {
      showAppSnackbar(
        'Videos didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  /// Replaces in-memory video categories with `video_categories` in Firestore.
  Future<void> refreshVideoCategoriesFromFirebase() async {
    try {
      final remote =
          await Get.find<FirebaseVideoCategoryService>().fetchVideoCategories();
      setVideoCategories(remote);
    } catch (_) {
      showAppSnackbar(
        'Video categories didn’t load',
        'Check your internet connection and try refreshing. If this keeps happening, contact support.',
      );
    }
  }

  void _replaceActivity(List<ActivityItemModel> remote) {
    activity.assignAll(remote);
  }

  /// Loads [activity] from the `recent_activity` Firestore collection.
  Future<void> refreshActivityFromFirebase() async {
    try {
      final remote =
          await Get.find<FirebaseRecentActivityService>().fetchRecent();
      _replaceActivity(remote);
    } catch (_) {
      showAppSnackbar(
        'Activity didn’t load',
        'Check your internet connection and try refreshing the dashboard.',
      );
    }
  }

  /// Writes one row to `recent_activity` and refreshes [activity] (errors are silent).
  Future<void> recordRecentActivity(
    String title,
    String subtitle, {
    String? kind,
  }) async {
    try {
      await Get.find<FirebaseRecentActivityService>().append(
        title: title,
        subtitle: subtitle,
        kind: kind,
      );
      final remote =
          await Get.find<FirebaseRecentActivityService>().fetchRecent();
      _replaceActivity(remote);
    } catch (_) {}
  }

  void refreshAll() {
    categories.assignAll(_repo.categoriesSnapshot);
    songs.assignAll(_repo.songsSnapshot);
    users.assignAll(_repo.usersSnapshot);
    subscriptions.assignAll(_repo.subscriptionsSnapshot);
    playlists.assignAll(_repo.playlistsSnapshot);
    videos.assignAll(_repo.videosSnapshot);
    videoCategories.assignAll(_repo.videoCategoriesSnapshot);
  }

  void setVideoCategories(List<VideoCategoryModel> items) {
    _repo.setVideoCategories(items);
    refreshAll();
  }

  void addVideoCategory(VideoCategoryModel c) {
    _repo.addVideoCategory(c);
    refreshAll();
  }

  void updateVideoCategory(String id, String name) {
    _repo.updateVideoCategory(id, name);
    refreshAll();
  }

  void deleteVideoCategory(String id) {
    _repo.deleteVideoCategory(id);
    refreshAll();
  }

  void setVideos(List<VideoModel> items) {
    _repo.setVideos(items);
    refreshAll();
  }

  void setPlaylists(List<PlaylistModel> playlists) {
    _repo.setPlaylists(playlists);
    refreshAll();
  }

  void addPlaylist(PlaylistModel p) {
    _repo.addPlaylist(p);
    refreshAll();
  }

  void updatePlaylist(String id, PlaylistModel next) {
    _repo.updatePlaylist(id, next);
    refreshAll();
  }

  void deletePlaylist(String id) {
    _repo.deletePlaylist(id);
    refreshAll();
  }

  void setPlaylistFeatured(String id, bool value) {
    _repo.setPlaylistFeatured(id, value);
    refreshAll();
  }

  void setPlaylistRecommended(String id, bool value) {
    _repo.setPlaylistRecommended(id, value);
    refreshAll();
  }

  String categoryName(String id) {
    try {
      return categories.firstWhere((e) => e.id == id).name;
    } catch (_) {
      return '—';
    }
  }

  /// Comma-separated category names for table cells and chips.
  String categoryNamesLabel(List<String> ids) {
    if (ids.isEmpty) return '—';
    final names = ids.map(categoryName).where((n) => n != '—').toList();
    return names.isEmpty ? '—' : names.join(', ');
  }

  String playlistName(String id) {
    try {
      return playlists.firstWhere((e) => e.id == id).name;
    } catch (_) {
      return '—';
    }
  }

  String playlistNamesLabel(List<String> ids) {
    if (ids.isEmpty) return '—';
    final names = ids.map(playlistName).where((n) => n != '—').toList();
    return names.isEmpty ? '—' : names.join(', ');
  }

  String videoCategoryName(String? id) {
    if (id == null || id.isEmpty) return '—';
    try {
      return videoCategories.firstWhere((e) => e.id == id).name;
    } catch (_) {
      return '—';
    }
  }

  void addCategory(CategoryModel c) {
    _repo.addCategory(c);
    refreshAll();
  }

  void setCategories(List<CategoryModel> categories) {
    _repo.setCategories(categories);
    refreshAll();
  }

  void updateCategory(String id, String name) {
    _repo.updateCategory(id, name);
    refreshAll();
  }

  void deleteCategory(String id) {
    _repo.deleteCategory(id);
    refreshAll();
  }

  void setSongs(List<SongModel> songs) {
    _repo.setSongs(songs);
    refreshAll();
  }

  void addSong(SongModel s) {
    _repo.addSong(s);
    refreshAll();
  }

  void updateSong(String id, SongModel next) {
    _repo.updateSong(id, next);
    refreshAll();
  }

  void deleteSong(String id) {
    _repo.deleteSong(id);
    refreshAll();
  }

  void setUsers(List<AppUserModel> users) {
    _repo.setUsers(users);
    refreshAll();
  }

  void addUser(AppUserModel u) {
    _repo.addUser(u);
    refreshAll();
  }

  void updateUser(String id, {String? displayName, bool? disabled}) {
    _repo.updateUser(id, displayName: displayName, disabled: disabled);
    refreshAll();
  }

  void deleteUser(String id) {
    _repo.deleteUser(id);
    refreshAll();
  }

  void upsertSubscription(SubscriptionModel s) {
    _repo.updateSubscription(s.id, s);
    refreshAll();
  }
}
