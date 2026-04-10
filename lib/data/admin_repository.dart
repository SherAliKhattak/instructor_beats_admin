import 'package:instructor_beats_admin/models/app_user_model.dart';
import 'package:instructor_beats_admin/models/category_model.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/models/subscription_model.dart';

class AdminRepository {
  AdminRepository() {
    _seed();
  }

  final List<CategoryModel> _categories = [];
  final List<SongModel> _songs = [];
  final List<AppUserModel> _users = [];
  final List<SubscriptionModel> _subscriptions = [];
  final List<PlaylistModel> _playlists = [];

  List<CategoryModel> get categoriesSnapshot => List.unmodifiable(_categories);
  List<PlaylistModel> get playlistsSnapshot => List.unmodifiable(_playlists);
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

  void _seed() {
    final now = DateTime.now();
    // Categories are sourced from Firebase; keep local seed empty.

    // Songs are now sourced from Firebase uploads via admin panel; keep local seed empty.

    _playlists.addAll([
      PlaylistModel(
        id: 'p1',
        name: 'Morning Energy',
        description: 'High-tempo openers for early sessions',
        coverImageUrl:
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=200',
        trackCount: 12,
        isFeatured: true,
        isRecommended: false,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      PlaylistModel(
        id: 'p2',
        name: 'Recovery & Flow',
        description: 'Low-impact cooldown and mobility',
        coverImageUrl:
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200',
        trackCount: 18,
        isFeatured: false,
        isRecommended: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      PlaylistModel(
        id: 'p3',
        name: 'Spin Essentials',
        description: 'Staple tracks for cycling classes',
        coverImageUrl:
            'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=200',
        trackCount: 24,
        isFeatured: true,
        isRecommended: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PlaylistModel(
        id: 'p4',
        name: 'HIIT Thunder',
        description: 'Short bursts, max effort',
        trackCount: 10,
        isFeatured: false,
        isRecommended: false,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      PlaylistModel(
        id: 'p5',
        name: 'Yoga Soundscapes',
        description: 'Ambient layers for mat work',
        trackCount: 15,
        isFeatured: false,
        isRecommended: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PlaylistModel(
        id: 'p6',
        name: 'Afternoon Push',
        description: 'Mid-day energy without burnout',
        coverImageUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
        trackCount: 14,
        isFeatured: false,
        isRecommended: false,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      PlaylistModel(
        id: 'p7',
        name: 'Studio Warm-Up',
        description: '5–10 min pre-class starters',
        coverImageUrl:
            'https://images.unsplash.com/photo-1599058945522-edd5a91d999b?w=200',
        trackCount: 8,
        isFeatured: true,
        isRecommended: false,
        createdAt: now.subtract(const Duration(days: 11)),
      ),
      PlaylistModel(
        id: 'p8',
        name: 'Techno Tread',
        description: 'Industrial beats for sprints',
        trackCount: 20,
        isFeatured: false,
        isRecommended: true,
        createdAt: now.subtract(const Duration(hours: 36)),
      ),
      PlaylistModel(
        id: 'p9',
        name: 'Latin Ride',
        description: 'Reggaeton & salsa-inspired spin set',
        coverImageUrl:
            'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=200',
        trackCount: 16,
        isFeatured: false,
        isRecommended: false,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      PlaylistModel(
        id: 'p10',
        name: 'Deep Focus Stretch',
        description: 'Long holds, minimal percussion',
        trackCount: 11,
        isFeatured: false,
        isRecommended: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

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
