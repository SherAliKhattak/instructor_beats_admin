import 'package:flutter/material.dart';

enum AdminShellSection {
  dashboard,
  songs,
  playlists,
  categories,
  users,
  subscriptions,
}

extension AdminShellSectionX on AdminShellSection {
  String get label => switch (this) {
        AdminShellSection.dashboard => 'Dashboard',
        AdminShellSection.songs => 'Songs',
        AdminShellSection.playlists => 'Playlists',
        AdminShellSection.categories => 'Categories',
        AdminShellSection.users => 'Users',
        AdminShellSection.subscriptions => 'Subscriptions',
      };

  IconData get icon => switch (this) {
        AdminShellSection.dashboard => Icons.dashboard_outlined,
        AdminShellSection.songs => Icons.library_music_outlined,
        AdminShellSection.playlists => Icons.queue_music_rounded,
        AdminShellSection.categories => Icons.category_outlined,
        AdminShellSection.users => Icons.people_outline,
        AdminShellSection.subscriptions => Icons.subscriptions_outlined,
      };
}
