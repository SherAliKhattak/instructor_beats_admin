import 'package:instructor_beats_admin/models/app_user_model.dart';
import 'package:instructor_beats_admin/models/category_model.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';
import 'package:instructor_beats_admin/models/video_category_model.dart';
import 'package:instructor_beats_admin/models/video_model.dart';

class AdminRepository {
  AdminRepository() {
    _seed();
  }

  final List<CategoryModel> _categories = [];
  final List<SongModel> _songs = [];
  final List<AppUserModel> _users = [];
  final List<SubscriptionModel> _subscriptions = [];
  final List<PlaylistModel> _playlists = [];
  final List<VideoModel> _videos = [];
  final List<VideoCategoryModel> _videoCategories = [];

  List<CategoryModel> get categoriesSnapshot => List.unmodifiable(_categories);
  List<PlaylistModel> get playlistsSnapshot => List.unmodifiable(_playlists);
  List<VideoModel> get videosSnapshot => List.unmodifiable(_videos);
  List<VideoCategoryModel> get videoCategoriesSnapshot =>
      List.unmodifiable(_videoCategories);
  List<SongModel> get songsSnapshot => List.unmodifiable(_songs);
  List<AppUserModel> get usersSnapshot => List.unmodifiable(_users);
  List<SubscriptionModel> get subscriptionsSnapshot =>
      List.unmodifiable(_subscriptions);

  void addCategory(CategoryModel c) => _categories.add(c);
  void setCategories(List<CategoryModel> categories) {
    _categories
      ..clear()
      ..addAll(categories);
  }

  void updateCategory(String id, String name) {
    final i = _categories.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _categories[i] = _categories[i].copyWith(name: name);
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((e) => e.id == id);
  }

  void addSong(SongModel s) => _songs.add(s);

  void setSongs(List<SongModel> songs) {
    _songs
      ..clear()
      ..addAll(songs);
  }

  void updateSong(String id, SongModel next) {
    final i = _songs.indexWhere((e) => e.id == id);
    if (i >= 0) _songs[i] = next;
  }

  void deleteSong(String id) {
    _songs.removeWhere((e) => e.id == id);
  }

  void addUser(AppUserModel u) => _users.add(u);

  void setUsers(List<AppUserModel> users) {
    _users
      ..clear()
      ..addAll(users);
  }

  void updateUser(String id, {String? displayName, bool? disabled}) {
    final i = _users.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _users[i] = _users[i].copyWith(
        displayName: displayName,
        disabled: disabled,
      );
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((e) => e.id == id);
  }

  void updateSubscription(String id, SubscriptionModel next) {
    final i = _subscriptions.indexWhere((e) => e.id == id);
    if (i >= 0) _subscriptions[i] = next;
  }

  void addPlaylist(PlaylistModel p) => _playlists.add(p);

  void setPlaylists(List<PlaylistModel> playlists) {
    _playlists
      ..clear()
      ..addAll(playlists);
  }

  void updatePlaylist(String id, PlaylistModel next) {
    final i = _playlists.indexWhere((e) => e.id == id);
    if (i >= 0) _playlists[i] = next;
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((e) => e.id == id);
  }

  void setPlaylistFeatured(String id, bool value) {
    final i = _playlists.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _playlists[i] = _playlists[i].copyWith(isFeatured: value);
    }
  }

  void setPlaylistRecommended(String id, bool value) {
    final i = _playlists.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _playlists[i] = _playlists[i].copyWith(isRecommended: value);
    }
  }

  void setVideos(List<VideoModel> videos) {
    _videos
      ..clear()
      ..addAll(videos);
  }

  void setVideoCategories(List<VideoCategoryModel> items) {
    _videoCategories
      ..clear()
      ..addAll(items);
  }

  void addVideoCategory(VideoCategoryModel c) => _videoCategories.add(c);

  void updateVideoCategory(String id, String name) {
    final i = _videoCategories.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _videoCategories[i] = _videoCategories[i].copyWith(name: name);
    }
  }

  void deleteVideoCategory(String id) {
    _videoCategories.removeWhere((e) => e.id == id);
  }

  void _seed() {
    final now = DateTime.now();
    // Categories are sourced from Firebase; keep local seed empty.

    // Songs are now sourced from Firebase uploads via admin panel; keep local seed empty.

    // Playlists are loaded from Firestore `playlists` after login.

    // Videos are loaded from Firestore `videos` after login.

    // Video categories are loaded from Firestore `video_categories` after login.

    // Users are loaded from Firestore `users` collection after login.

    _subscriptions.addAll([
      SubscriptionModel(
        id: 'sub1',
        userId: 'u1',
        userLabel: 'Alex Rivera',
        plan: 'Annual',
        status: SubscriptionStatus.active,
        currentPeriodEnd: now.add(const Duration(days: 120)),
        stripeSubscriptionId: 'sub_1',
      ),
      SubscriptionModel(
        id: 'sub2',
        userId: 'u2',
        userLabel: 'Jamie Lee',
        plan: 'Monthly',
        status: SubscriptionStatus.active,
        currentPeriodEnd: now.add(const Duration(days: 14)),
        stripeSubscriptionId: 'sub_2',
      ),
    ]);

  }
}
