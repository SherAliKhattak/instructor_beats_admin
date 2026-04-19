import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/formatters.dart';
import 'package:instructor_beats_admin/core/widgets/storage_or_network_image.dart';
import 'package:instructor_beats_admin/core/widgets/empty_state_message.dart';
import 'package:instructor_beats_admin/core/widgets/pagination_controls.dart';
import 'package:instructor_beats_admin/core/widgets/section_header.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/videos/controllers/videos_controller.dart';
import 'package:instructor_beats_admin/features/videos/widgets/video_form_dialog.dart';
import 'package:instructor_beats_admin/models/video_model.dart';

class VideosView extends GetView<VideosController> {
  const VideosView({super.key});

  Future<void> _confirmDelete(BuildContext context, VideoModel v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete video?'),
        content: Text('“${v.title}” will be removed from the library.'),
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
      final removed = await controller.removeVideo(v.id);
      if (removed) {
        await data.recordRecentActivity(
          'Video deleted',
          '“${v.title}” was removed from your videos.',
          kind: 'video_deleted',
        );
        deferredSnackbar(
          'Video removed',
          'It’s no longer available in the app.',
        );
      }
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
          SectionHeader(
            title: 'Videos',
            trailing: FilledButton.icon(
              onPressed: () => showVideoFormDialog(context),
              style: FilledButton.styleFrom(
                minimumSize: Size(0, AdminUi.controlHeight),
                maximumSize: Size(double.infinity, AdminUi.controlHeight),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add video'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage on-demand or class videos. Published items are visible in the app.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search title, description, or category',
            ),
            onChanged: controller.setSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              controller.searchQuery.value;
              controller.currentPage.value;
              final items = controller.pageItems;
              final listEmpty = controller.filtered.isEmpty;
              if (listEmpty) {
                final noVideos = controller.data.videos.isEmpty;
                return Column(
                  children: [
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: EmptyStateMessage(
                          icon: Icons.video_library_outlined,
                          title: noVideos
                              ? 'No videos yet'
                              : 'No matching videos',
                          message: noVideos
                              ? 'Add a video with the button above, or pull them in from your Firestore `videos` collection.'
                              : 'Try another search or clear the box to see all videos.',
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
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _VideoCard(
                          v: items[i],
                          controller: controller,
                          categoryLabel: controller.data
                              .videoCategoryName(items[i].categoryId),
                          onEdit: () => showVideoFormDialog(
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
                              columnSpacing: 20,
                              horizontalMargin: 18,
                              headingRowHeight: 52,
                              dataRowMinHeight: 72,
                              dataRowMaxHeight: 88,
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(label: Text('Preview')),
                                DataColumn(label: Text('Title')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Published')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: List.generate(items.length, (i) {
                                final v = items[i];
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
                                    DataCell(
                                      _VideoThumbnailPreview(
                                        video: v,
                                        width: 88,
                                        height: 56,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        v.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        controller.data
                                            .videoCategoryName(v.categoryId),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          v.description ?? '—',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Switch.adaptive(
                                        value: v.isPublished,
                                        activeTrackColor: scheme.primary
                                            .withValues(alpha: 0.35),
                                        thumbColor:
                                            WidgetStateProperty.resolveWith(
                                          (states) => states.contains(
                                                WidgetState.selected,
                                              )
                                              ? scheme.primary
                                              : scheme.outline,
                                        ),
                                        onChanged: (pub) => controller
                                            .setPublished(v.id, pub),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        adminDateFormat.format(v.createdAt),
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
                                                showVideoFormDialog(
                                              context,
                                              existing: v,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          _TableIcon(
                                            tooltip: 'Copy video link',
                                            icon: Icons.link_rounded,
                                            onPressed: () async {
                                              await Clipboard.setData(
                                                ClipboardData(text: v.videoUrl),
                                              );
                                              deferredSnackbar(
                                                'Copied',
                                                'Video link is on the clipboard.',
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 6),
                                          _TableIcon(
                                            tooltip: 'Delete',
                                            icon: Icons.delete_outline,
                                            danger: true,
                                            onPressed: () =>
                                                _confirmDelete(context, v),
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

/// Poster image when set; otherwise a neutral video placeholder (URL is never shown).
class _VideoThumbnailPreview extends StatelessWidget {
  const _VideoThumbnailPreview({
    required this.video,
    required this.width,
    required this.height,
  });

  final VideoModel video;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = video.thumbnailUrl;
    Widget base;
    if (url == null || url.isEmpty) {
      base = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.videocam_outlined,
          size: (width * 0.38).clamp(20.0, 32.0),
          color: scheme.onSurfaceVariant,
        ),
      );
    } else {
      base = StorageOrNetworkImage(
        url: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
        errorWidget: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: scheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        base,
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.v,
    required this.controller,
    required this.categoryLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final VideoModel v;
  final VideosController controller;
  final String categoryLabel;
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
                _VideoThumbnailPreview(
                  video: v,
                  width: 56,
                  height: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (v.description != null &&
                          v.description!.isNotEmpty)
                        Text(
                          v.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        '$categoryLabel • ${adminDateFormat.format(v.createdAt)}',
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
                  tooltip: 'Copy video link',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: v.videoUrl));
                    deferredSnackbar(
                      'Copied',
                      'Video link is on the clipboard.',
                    );
                  },
                  icon: Icon(Icons.link_rounded, color: scheme.onSurfaceVariant),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Published'),
              subtitle: const Text('Visible in the app'),
              value: v.isPublished,
              activeTrackColor: scheme.primary.withValues(alpha: 0.35),
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? scheme.primary
                    : scheme.outline,
              ),
              onChanged: (pub) => controller.setPublished(v.id, pub),
            ),
          ],
        ),
      ),
    );
  }
}
