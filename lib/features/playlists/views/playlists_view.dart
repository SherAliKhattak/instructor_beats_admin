import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/core/widgets/section_header.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/playlists/controllers/playlists_controller.dart';
import 'package:instructor_beats_admin/features/playlists/widgets/playlist_form_dialog.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';

/// Playlists: CRUD + featured / recommended curation.
class PlaylistsView extends GetView<PlaylistsController> {
  const PlaylistsView({super.key});

  Future<void> _confirmDelete(BuildContext context, PlaylistModel p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete playlist?'),
        content: Text('“${p.name}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final data = Get.find<AdminDataController>();
      controller.removePlaylist(p.id);
      await data.recordRecentActivity(
        'Playlist deleted',
        '“${p.name}” was removed from your playlists.',
        kind: 'playlist_deleted',
      );
      deferredSnackbar(
        'Playlist removed',
        'Listeners won’t see it in the app anymore.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Playlists'),
          const SizedBox(height: 8),
          Text(
            'Edit playlists and toggle featured or recommended. These settings are independent.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (wide)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search playlist name or description',
                    ),
                    onChanged: controller.setSearch,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search playlist name or description',
                  ),
                  onChanged: controller.setSearch,
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              controller.searchQuery.value;
              controller.currentPage.value;
              final items = controller.pageItems;
              final listEmpty = controller.filtered.isEmpty;
              if (listEmpty) {
                final noPlaylists = controller.data.playlists.isEmpty;
                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: EmptyStateMessage(
                          icon: Icons.queue_music_rounded,
                          title: noPlaylists
                              ? 'No playlists yet'
                              : 'No matching playlists',
                          message: noPlaylists
                              ? 'Playlists will appear here once they are added to your catalog. You can edit or remove them from this screen.'
                              : 'Try another search or clear the box to see all playlists.',
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
              }
              if (!wide) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _PlaylistCard(
                          p: items[i],
                          controller: controller,
                          onEdit: () => showPlaylistFormDialog(
                            context,
                            existing: items[i],
                          ),
                          onDelete: () => _confirmDelete(context, items[i]),
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
              }
              return Column(
                children: [
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    scheme.surfaceContainerHighest,
                                  ),
                                  headingTextStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  dataTextStyle: TextStyle(
                                    fontSize: 13,
                                    color: scheme.onSurface,
                                  ),
                                  columnSpacing: 24,
                                  horizontalMargin: 18,
                                  headingRowHeight: 52,
                                  dataRowMinHeight: 64,
                                  dataRowMaxHeight: 72,
                                  dividerThickness: 0.5,
                                  columns: const [
                                    DataColumn(label: Text('Cover')),
                                    DataColumn(label: Text('Playlist')),
                                    DataColumn(label: Text('Tracks')),
                                    DataColumn(label: Text('Featured')),
                                    DataColumn(label: Text('Recommended')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: List.generate(items.length, (i) {
                                    final p = items[i];
                                    return DataRow.byIndex(
                                      index: i,
                                      color: WidgetStateProperty.resolveWith(
                                        (_) => i.isEven
                                            ? Colors.transparent
                                            : scheme.surface.withValues(
                                                alpha: 0.2,
                                              ),
                                      ),
                                      cells: [
                                        DataCell(_CoverThumb(playlist: p)),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (p.description != null &&
                                                  p.description!.isNotEmpty)
                                                Text(
                                                  p.description!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        scheme.onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text('${p.trackCount}')),
                                        DataCell(
                                          Switch.adaptive(
                                            value: p.isFeatured,
                                            activeTrackColor: scheme.primary
                                                .withValues(alpha: 0.35),
                                            thumbColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) =>
                                                      states.contains(
                                                        WidgetState.selected,
                                                      )
                                                      ? scheme.primary
                                                      : scheme.outline,
                                                ),
                                            onChanged: (v) =>
                                                controller.setFeatured(p.id, v),
                                          ),
                                        ),
                                        DataCell(
                                          Switch.adaptive(
                                            value: p.isRecommended,
                                            activeTrackColor: scheme.primary
                                                .withValues(alpha: 0.35),
                                            thumbColor:
                                                WidgetStateProperty.resolveWith(
                                                  (states) =>
                                                      states.contains(
                                                        WidgetState.selected,
                                                      )
                                                      ? scheme.primary
                                                      : scheme.outline,
                                                ),
                                            onChanged: (v) => controller
                                                .setRecommended(p.id, v),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            adminDateFormat.format(p.createdAt),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _TableIcon(
                                                tooltip: 'Edit',
                                                icon: Icons.edit_outlined,
                                                onPressed: () =>
                                                    showPlaylistFormDialog(
                                                      context,
                                                      existing: p,
                                                    ),
                                              ),
                                              const SizedBox(width: 6),
                                              _TableIcon(
                                                tooltip: 'Delete',
                                                icon: Icons.delete_outline,
                                                danger: true,
                                                onPressed: () =>
                                                    _confirmDelete(context, p),
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
                  const SizedBox(height: 12),
                  PaginationControls(
                    currentPage: controller.currentPage.value,
                    totalItems: controller.filtered.length,
                    itemsPerPage: controller.itemsPerPage,
                    onPageChanged: controller.setPage,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TableIcon extends StatelessWidget {
  const _TableIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
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

class _CoverThumb extends StatelessWidget {
  const _CoverThumb({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final url = playlist.coverImageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.queue_music_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.p,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  final PlaylistModel p;
  final PlaylistsController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverThumb(playlist: p),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (p.description != null && p.description!.isNotEmpty)
                        Text(
                          p.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        '${p.trackCount} tracks • ${adminDateFormat.format(p.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Featured'),
              subtitle: const Text('Show in featured carousel'),
              value: p.isFeatured,
              activeTrackColor: scheme.primary.withValues(alpha: 0.35),
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? scheme.primary
                    : scheme.outline,
              ),
              onChanged: (v) => controller.setFeatured(p.id, v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recommended'),
              subtitle: const Text('Show in recommended section'),
              value: p.isRecommended,
              activeTrackColor: scheme.primary.withValues(alpha: 0.35),
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? scheme.primary
                    : scheme.outline,
              ),
              onChanged: (v) => controller.setRecommended(p.id, v),
            ),
          ],
        ),
      ),
    );
  }
}
