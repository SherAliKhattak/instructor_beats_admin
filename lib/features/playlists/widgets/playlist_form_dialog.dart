import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/playlists/controllers/playlists_controller.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';

Future<void> showPlaylistFormDialog(
  BuildContext context, {
  PlaylistModel? existing,
}) async {
  final controller = Get.find<PlaylistsController>();
  final h = AdminUi.controlHeight;
  final nameC = TextEditingController(text: existing?.name ?? '');
  final descC = TextEditingController(text: existing?.description ?? '');
  final coverC = TextEditingController(text: existing?.coverImageUrl ?? '');
  final tracksC = TextEditingController(
    text: existing != null ? '${existing.trackCount}' : '12',
  );
  var featured = existing?.isFeatured ?? false;
  var recommended = existing?.isRecommended ?? false;

  final scheme = Theme.of(context).colorScheme;

  ButtonStyle outlineStyle() => OutlinedButton.styleFrom(
        minimumSize: Size(0, h),
        maximumSize: Size(double.infinity, h),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
      );

  ButtonStyle filledStyle() => FilledButton.styleFrom(
        minimumSize: Size(0, h),
        maximumSize: Size(double.infinity, h),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      );

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ) ??
          TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          );

      return Dialog(
        backgroundColor: scheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              void close() => Navigator.pop(dialogCtx);

              Future<void> saveAndClose() async {
                final name = nameC.text.trim();
                if (name.isEmpty) return;
                final tracks = int.tryParse(tracksC.text.trim()) ?? 0;
                final now = DateTime.now();
                final cover = coverC.text.trim();
                final desc = descC.text.trim();

                final playlist = PlaylistModel(
                  id: existing?.id ?? 'p_${now.millisecondsSinceEpoch}',
                  name: name,
                  description: desc.isEmpty ? null : desc,
                  coverImageUrl: cover.isEmpty ? null : cover,
                  trackCount: tracks.clamp(0, 9999),
                  isFeatured: featured,
                  isRecommended: recommended,
                  createdAt: existing?.createdAt ?? now,
                );

                if (existing == null) {
                  controller.addPlaylist(playlist);
                } else {
                  controller.replacePlaylist(existing.id, playlist);
                }
                final data = Get.find<AdminDataController>();
                await data.recordRecentActivity(
                  existing == null ? 'New playlist' : 'Playlist updated',
                  existing == null
                      ? '“$name” was added to your playlists.'
                      : 'Your changes to “$name” were saved.',
                  kind: existing == null ? 'playlist_added' : 'playlist_updated',
                );
                deferredSnackbar(
                  existing == null ? 'Playlist saved' : 'Changes saved',
                  existing == null
                      ? '“$name” is in your playlist list.'
                      : 'Updates to “$name” are saved.',
                );
                if (dialogCtx.mounted) close();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existing == null ? 'Add playlist' : 'Edit playlist',
                                style: titleStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Track order and songs are managed separately.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: close,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    SizedBox(height: AdminUi.sectionGap),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              label: 'Name',
                              placeholder: 'Playlist title',
                              leadingIcon: Icons.queue_music_rounded,
                              controller: nameC,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Description',
                              placeholder: 'Short summary',
                              leadingIcon: Icons.notes_outlined,
                              controller: descC,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Cover image URL',
                              placeholder: 'https://…',
                              leadingIcon: Icons.image_outlined,
                              controller: coverC,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Track count',
                              placeholder: '0',
                              leadingIcon: Icons.numbers_rounded,
                              controller: tracksC,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            Material(
                              color: scheme.surfaceContainerHighest.withValues(
                                alpha: 0.45,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  SwitchListTile.adaptive(
                                    value: featured,
                                    onChanged: (v) =>
                                        setDialogState(() => featured = v),
                                    title: const Text('Featured'),
                                    subtitle: const Text(
                                      'Show in featured carousel',
                                    ),
                                    activeTrackColor: AppColors.primary
                                        .withValues(alpha: 0.55),
                                  ),
                                  SwitchListTile.adaptive(
                                    value: recommended,
                                    onChanged: (v) =>
                                        setDialogState(() => recommended = v),
                                    title: const Text('Recommended'),
                                    subtitle: const Text(
                                      'Show in recommended section',
                                    ),
                                    activeTrackColor: AppColors.primary
                                        .withValues(alpha: 0.55),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AdminUi.sectionGap),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: OutlinedButton(
                              onPressed: close,
                              style: outlineStyle(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: FilledButton(
                              onPressed: saveAndClose,
                              style: filledStyle(),
                              child: Text(existing == null ? 'Add' : 'Save'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
