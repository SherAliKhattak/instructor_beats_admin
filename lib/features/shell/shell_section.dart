import 'package:flutter/material.dart';

enum AdminShellSection {
  dashboard,
  songs,
  playlists,
  videos,
  videoCategories,
  categories,
  users,
  subscriptions,
}

extension AdminShellSectionX on AdminShellSection {
  String get label => switch (this) {
        AdminShellSection.dashboard => 'Dashboard',
        AdminShellSection.songs => 'Songs',
        AdminShellSection.playlists => 'Playlists',
        AdminShellSection.videos => 'Videos',
        AdminShellSection.videoCategories => 'Video categories',
        AdminShellSection.categories => 'Song categories',
        AdminShellSection.users => 'Users',
        AdminShellSection.subscriptions => 'Subscriptions',
      };

  IconData get icon => switch (this) {
        AdminShellSection.dashboard => Icons.dashboard_outlined,
        AdminShellSection.songs => Icons.library_music_outlined,
        AdminShellSection.playlists => Icons.queue_music_rounded,
        AdminShellSection.videos => Icons.video_library_outlined,
        AdminShellSection.videoCategories => Icons.video_settings_outlined,
        AdminShellSection.categories => Icons.category_outlined,
        AdminShellSection.users => Icons.people_outline,
        AdminShellSection.subscriptions => Icons.subscriptions_outlined,
      };
}
