import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/songs/controllers/songs_controller.dart';
import 'package:instructor_beats_admin/features/songs/widgets/song_form_sheet.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';

class SongsView extends GetView<SongsController> {
  const SongsView({super.key});

  Future<void> _confirmDelete(BuildContext context, SongModel song) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete song?'),
        content: Text('“${song.title}” will be removed from the library.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final data = Get.find<AdminDataController>();
      data.deleteSong(song.id);
      controller.clampPage();
      await data.recordRecentActivity(
        'Song removed',
        '“${song.title}” was removed from the catalog.',
        kind: 'song_deleted',
      );
      deferredSnackbar(
        'Song removed',
        'It’s no longer in your catalog.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Get.find<AdminDataController>();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final controlHeight = AdminUi.controlHeight;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: controlHeight,
                    child: _SongsSearchField(
                      hintText: 'Search title or artist',
                      onChanged: controller.setSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  child: SizedBox(
                    height: controlHeight,
                    child: Obx(
                      () => DropdownButtonFormField<String?>(
                        // ignore: deprecated_member_use
                        value: controller.categoryFilterId.value,
                        decoration: _songsFilterDecoration(
                          context,
                          labelText: 'Category',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          for (final c in data.categories)
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                        ],
                        onChanged: controller.setCategoryFilter,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: controlHeight,
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () =>
                          controller.setActiveOnly(!controller.activeOnly.value),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, controlHeight),
                        maximumSize: Size(double.infinity, controlHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(
                          color: controller.activeOnly.value
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        backgroundColor: controller.activeOnly.value
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.14)
                            : null,
                      ),
                      icon: Icon(
                        controller.activeOnly.value
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        size: 18,
                      ),
                      label: const Text('Active only'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: controlHeight,
                  child: FilledButton.icon(
                    onPressed: () => showSongFormSheet(context),
                    style: FilledButton.styleFrom(
                      minimumSize: Size(0, controlHeight),
                      maximumSize: Size(double.infinity, controlHeight),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add song'),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: controlHeight,
                  child: _SongsSearchField(
                    hintText: 'Search title or artist',
                    onChanged: controller.setSearch,
                  ),
                ),
                SizedBox(height: AdminUi.fieldGap),
                SizedBox(
                  height: controlHeight,
                  child: Obx(
                    () => DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: controller.categoryFilterId.value,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All'),
                        ),
                        for (final c in data.categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: controller.setCategoryFilter,
                    ),
                  ),
                ),
                SizedBox(height: AdminUi.fieldGap),
                SizedBox(
                  height: controlHeight,
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () =>
                          controller.setActiveOnly(!controller.activeOnly.value),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(0, controlHeight),
                        maximumSize: Size(double.infinity, controlHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(
                          color: controller.activeOnly.value
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        backgroundColor: controller.activeOnly.value
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.14)
                            : null,
                      ),
                      icon: Icon(
                        controller.activeOnly.value
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        size: 18,
                      ),
                      label: const Text('Active only'),
                    ),
                  ),
                ),
                SizedBox(height: AdminUi.fieldGap),
                SizedBox(
                  height: controlHeight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => showSongFormSheet(context),
                      style: FilledButton.styleFrom(
                        minimumSize: Size(0, controlHeight),
                        maximumSize: Size(double.infinity, controlHeight),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add song'),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () {
                controller.searchQuery.value;
                controller.categoryFilterId.value;
                controller.activeOnly.value;
                controller.currentPage.value;
                final items = controller.pageItems;
                final listEmpty = controller.filtered.isEmpty;
                if (listEmpty) {
                  final noSongs = data.songs.isEmpty;
                  final hasQ =
                      controller.searchQuery.value.trim().isNotEmpty;
                  final hasCat = controller.categoryFilterId.value != null;
                  final activeOnly = controller.activeOnly.value;
                  final narrowed = noSongs
                      ? false
                      : (hasQ || hasCat || activeOnly);
                  return Column(
                    children: [
                      Expanded(
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: EmptyStateMessage(
                            icon: Icons.library_music_outlined,
                            title: noSongs
                                ? 'No songs in your library yet'
                                : (narrowed
                                    ? 'No songs match'
                                    : 'Nothing to show'),
                            message: noSongs
                                ? 'Tap Add song to create your first track. Add a category first if you have not already.'
                                : (narrowed
                                    ? 'Try a different search, set Category to All, or turn off Active only.'
                                    : 'If you expected songs here, refresh the page or check your connection.'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaginationControls(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.filtered.length,
                        itemsPerPage: controller.itemsPerPage,
                        onPageChanged: (p) => controller.setPage(p),
                      ),
                    ],
                  );
                }
                if (!wide) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final s = items[i];
                            return _SongCard(
                              song: s,
                              categoryName: data.categoryName(s.categoryId),
                              onEdit: () => showSongFormSheet(context, existing: s),
                              onDelete: () => _confirmDelete(context, s),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      PaginationControls(
                        currentPage: controller.currentPage.value,
                        totalItems: controller.filtered.length,
                        itemsPerPage: controller.itemsPerPage,
                        onPageChanged: (p) => controller.setPage(p),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: SingleChildScrollView(
                                child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.2,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              dataTextStyle: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              columnSpacing: 24,
                              horizontalMargin: 18,
                              headingRowHeight: 52,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 62,
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(label: Text('Image')),
                                DataColumn(label: Text('Title')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('BPM')),
                                DataColumn(label: Text('Duration')),
                                DataColumn(label: Text('Active')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: List.generate(items.length, (i) {
                                final s = items[i];
                                return DataRow.byIndex(
                                  index: i,
                                  color: WidgetStateProperty.resolveWith(
                                    (_) => i.isEven
                                        ? Colors.transparent
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surface.withValues(alpha: 0.2),
                                  ),
                                    cells: [
                                      DataCell(
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            s.imageUrl,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.music_note),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              s.artist,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(data.categoryName(s.categoryId))),
                                      DataCell(Text('${s.bpm}')),
                                      DataCell(Text(formatDurationMmSs(s.durationSec))),
                                      DataCell(
                                        _SongStatusBadge(
                                          active: s.isActive,
                                        ),
                                      ),
                                      DataCell(Text(adminDateFormat.format(s.createdAt))),
                                      DataCell(
                                        Row(
                                          children: [
                                            _TableActionIcon(
                                              tooltip: 'Edit',
                                              onPressed: () => showSongFormSheet(context, existing: s),
                                              icon: Icons.edit_outlined,
                                            ),
                                            const SizedBox(width: 6),
                                            _TableActionIcon(
                                              tooltip: 'Delete',
                                              onPressed: () => _confirmDelete(context, s),
                                              icon: Icons.delete_outline,
                                              danger: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                              }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaginationControls(
                      currentPage: controller.currentPage.value,
                      totalItems: controller.filtered.length,
                      itemsPerPage: controller.itemsPerPage,
                      onPageChanged: controller.setPage,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _songsFilterDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    isDense: true,
    filled: true,
    fillColor: AppColors.fieldFill,
    prefixIcon: hintText != null ? const Icon(Icons.search) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

class _SongsSearchField extends StatelessWidget {
  const _SongsSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: _songsFilterDecoration(
        context,
        hintText: hintText,
      ),
      onChanged: onChanged,
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  final SongModel song;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    song.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.music_note, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        song.artist,
                        style: TextStyle(color: secondary),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(categoryName)),
                Chip(label: Text('${song.bpm} BPM')),
                Chip(label: Text(formatDurationMmSs(song.durationSec))),
                Chip(
                  label: Text(song.isActive ? 'Active' : 'Inactive'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SongStatusBadge extends StatelessWidget {
  const _SongStatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.greenAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionIcon extends StatelessWidget {
  const _TableActionIcon({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.danger = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? Colors.redAccent : scheme.onSurfaceVariant;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
