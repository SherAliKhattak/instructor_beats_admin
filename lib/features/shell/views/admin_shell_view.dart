import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/features/auth/controllers/auth_controller.dart';
import 'package:instructor_beats_admin/features/categories/views/categories_view.dart';
import 'package:instructor_beats_admin/features/playlists/views/playlists_view.dart';
import 'package:instructor_beats_admin/features/dashboard/views/dashboard_view.dart';
import 'package:instructor_beats_admin/features/shell/controllers/shell_controller.dart';
import 'package:instructor_beats_admin/features/shell/shell_section.dart';
import 'package:instructor_beats_admin/features/songs/views/songs_view.dart';
import 'package:instructor_beats_admin/features/subscriptions/views/subscriptions_view.dart';
import 'package:instructor_beats_admin/features/users/views/users_view.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';
import 'package:instructor_beats_admin/theme/app_theme.dart';

/// Responsive admin shell — Smart HR–inspired dark dashboard.
class AdminShellView extends GetView<ShellController> {
  AdminShellView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _index(AdminShellSection s) => AdminShellSection.values.indexOf(s);

  AdminShellSection _section(int i) => AdminShellSection.values[i];

  void _select(AdminShellSection section) {
    controller.goTo(section);
    final state = _scaffoldKey.currentState;
    if (state?.isDrawerOpen ?? false) {
      state!.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dashboardDark,
      child: Builder(
        builder: (context) {
          final width = MediaQuery.sizeOf(context).width;
          final useDrawer = width < 900;
          final useRail = width >= 600 && width < 900;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: DashColors.canvas,
            drawer: useDrawer
                ? Drawer(
                    backgroundColor: DashColors.sidebar,
                    child: SafeArea(
                      child: _SidebarNav(
                        expanded: true,
                        current: controller.current.value,
                        onSelect: _select,
                        onLogout: () => Get.find<AuthController>().logout(),
                      ),
                    ),
                  )
                : null,
            body: Row(
              children: [
                if (!useDrawer)
                  useRail
                      ? Obx(
                          () => NavigationRail(
                            backgroundColor: DashColors.sidebar,
                            selectedIndex: _index(controller.current.value),
                            onDestinationSelected: (i) => _select(_section(i)),
                            labelType: NavigationRailLabelType.all,
                            useIndicator: true,
                            destinations: [
                              for (final s in AdminShellSection.values)
                                NavigationRailDestination(
                                  icon: Icon(s.icon),
                                  label: Text(s.label),
                                ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 252,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: DashColors.sidebar,
                              border: Border(
                                right: BorderSide(color: DashColors.border),
                              ),
                            ),
                            child: Obx(
                              () => _SidebarNav(
                                expanded: true,
                                current: controller.current.value,
                                onSelect: _select,
                                onLogout: () => Get.find<AuthController>().logout(),
                              ),
                            ),
                          ),
                        ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => _TopBar(
                          scaffoldKey: _scaffoldKey,
                          useDrawer: useDrawer,
                          sectionTitle: controller.current.value.label,
                        ),
                      ),
                      Expanded(
                        child: ColoredBox(
                          color: DashColors.surface,
                          child: Obx(
                            () {
                              switch (controller.current.value) {
                                case AdminShellSection.dashboard:
                                  return const DashboardView();
                                case AdminShellSection.songs:
                                  return const SongsView();
                                case AdminShellSection.playlists:
                                  return const PlaylistsView();
                                case AdminShellSection.categories:
                                  return const CategoriesView();
                                case AdminShellSection.users:
                                  return const UsersView();
                                case AdminShellSection.subscriptions:
                                  return const SubscriptionsView();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.scaffoldKey,
    required this.useDrawer,
    required this.sectionTitle,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool useDrawer;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashColors.surface,
      child: Container(
        padding: EdgeInsets.fromLTRB(useDrawer ? 8 : 24, 16, 24, 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DashColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (useDrawer)
              IconButton(
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: DashColors.textPrimary),
              ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: DashColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 14,
                      color: DashColors.textMuted.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                Get.closeAllSnackbars();
                Get.snackbar(
                  'Notifications',
                  'You’re all caught up — nothing new right now.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.notifications_outlined, color: DashColors.textMuted),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () {
                Get.closeAllSnackbars();
                Get.snackbar(
                  'Settings',
                  'Settings aren’t available in this version yet.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              icon: const Icon(Icons.settings_outlined, color: DashColors.textMuted),
            ),
            IconButton(
              tooltip: 'Log out',
              onPressed: () => Get.find<AuthController>().logout(),
              icon: const Icon(Icons.logout_rounded, color: DashColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({
    required this.expanded,
    required this.current,
    required this.onSelect,
    required this.onLogout,
  });

  final bool expanded;
  final AdminShellSection current;
  final void Function(AdminShellSection) onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                height: expanded ? 48 : 36,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: expanded ? 48 : 36,
                  height: expanded ? 48 : 36,
                  decoration: BoxDecoration(
                    color: DashColors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'IB',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: Text(
            expanded ? 'ADMIN PANEL' : '',
            style: TextStyle(
              letterSpacing: 0.6,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: DashColors.textMuted.withValues(alpha: 0.85),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final s in AdminShellSection.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: current == s
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: current == s
                              ? AppColors.primary.withValues(alpha: 0.65)
                              : Colors.transparent,
                        ),
                      ),
                      leading: Icon(
                        s.icon,
                        color: current == s
                            ? AppColors.primary
                            : DashColors.textMuted,
                        size: 22,
                      ),
                      title: expanded
                          ? Text(
                              s.label,
                              style: TextStyle(
                                fontWeight: current == s
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: current == s
                                    ? AppColors.title
                                    : DashColors.textMuted,
                                fontSize: 14,
                              ),
                            )
                          : null,
                      onTap: () => onSelect(s),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: DashColors.border),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: DashColors.textMuted),
          title: expanded
              ? const Text(
                  'Log out',
                  style: TextStyle(color: DashColors.textMuted),
                )
              : null,
          onTap: () => onLogout(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
