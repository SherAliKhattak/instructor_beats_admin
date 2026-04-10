import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/services/firebase_song_service.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';
import 'package:instructor_beats_admin/theme/app_text_styles.dart';

Future<void> showSongFormSheet(
  BuildContext context, {
  SongModel? existing,
}) async {
  final h = AdminUi.controlHeight;
  final data = Get.find<AdminDataController>();
  if (data.categories.isEmpty) {
    Get.snackbar(
      'Add a category first',
      'Create at least one category, then you can add songs to it.',
    );
    return;
  }
  final titleC = TextEditingController(text: existing?.title ?? '');
  final artistC = TextEditingController(text: existing?.artist ?? '');
  final bpmC = TextEditingController(
    text: existing != null ? '${existing.bpm}' : '128',
  );
  final durationC = TextEditingController(
    text: existing != null
        ? '${existing.durationSec ~/ 60}:${(existing.durationSec % 60).toString().padLeft(2, '0')}'
        : '3:30',
  );
  final imageC = TextEditingController(text: existing?.imageUrl ?? '');
  final audioC = TextEditingController(text: existing?.audioUrl ?? '');
  var categoryId = existing?.categoryId ?? data.categories.first.id;
  var active = existing?.isActive ?? true;
  var saving = false;
  String? pickedImageName;
  String? pickedAudioName;
  PlatformFile? pickedImageFile;
  PlatformFile? pickedAudioFile;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      InputDecoration categoryDecoration(ColorScheme scheme) {
        final base = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        );
        return InputDecoration(
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          prefixIcon: Icon(
            Icons.folder_outlined,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
          border: base,
          enabledBorder: base,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: scheme.brightness == Brightness.dark
                  ? scheme.primary
                  : AppColors.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          isDense: true,
        );
      }

      Widget sectionLabel(String text, ColorScheme scheme) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        );
      }

      ButtonStyle outlineActionStyle(ColorScheme scheme) {
        return OutlinedButton.styleFrom(
          minimumSize: Size(0, h),
          maximumSize: Size(double.infinity, h),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
        );
      }

      ButtonStyle filledActionStyle() {
        return FilledButton.styleFrom(
          minimumSize: Size(0, h),
          maximumSize: Size(double.infinity, h),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
      }

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.paddingOf(ctx).bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final scheme = Theme.of(ctx).colorScheme;

              int parseDuration(String raw) {
                final parts = raw.trim().split(':');
                if (parts.length == 2) {
                  final m = int.tryParse(parts[0]) ?? 0;
                  final s = int.tryParse(parts[1]) ?? 0;
                  return m * 60 + s;
                }
                return int.tryParse(raw) ?? 180;
              }

              Future<void> saveSong() async {
                if (saving) return;
                setState(() => saving = true);
                final now = DateTime.now();
                final service = Get.find<FirebaseSongService>();
                final id = existing?.id ?? 's_${now.millisecondsSinceEpoch}';

                // Basic validation
                final title = titleC.text.trim();
                final artist = artistC.text.trim();
                if (title.isEmpty || artist.isEmpty) {
                  setState(() => saving = false);
                  Get.snackbar(
                    'Title and artist needed',
                    'Please fill in both the song title and artist name.',
                  );
                  return;
                }

                final bpmValue = int.tryParse(bpmC.text.trim());
                if (bpmValue == null || bpmValue <= 0) {
                  setState(() => saving = false);
                  Get.snackbar(
                    'Check the tempo (BPM)',
                    'Enter beats per minute as a positive number (e.g. 120).',
                  );
                  return;
                }

                final rawDuration = durationC.text.trim();
                if (rawDuration.isEmpty) {
                  setState(() => saving = false);
                  Get.snackbar(
                    'Duration needed',
                    'Enter how long the track is (for example 3:30).',
                  );
                  return;
                }

                var imageUrl = imageC.text.trim();
                var audioUrl = audioC.text.trim();

                if (pickedImageFile?.bytes != null) {
                  try {
                    imageUrl = await service.uploadImage(
                      songId: id,
                      bytes: pickedImageFile!.bytes!,
                      fileName: pickedImageFile!.name,
                    );
                  } catch (_) {
                    setState(() => saving = false);
                    Get.snackbar(
                      'Cover image didn’t upload',
                      'Check your connection and try again, or paste an image link instead.',
                    );
                    return;
                  }
                }

                if (pickedAudioFile?.bytes != null) {
                  try {
                    audioUrl = await service.uploadAudio(
                      songId: id,
                      bytes: pickedAudioFile!.bytes!,
                      fileName: pickedAudioFile!.name,
                    );
                  } catch (_) {
                    setState(() => saving = false);
                    Get.snackbar(
                      'Audio didn’t upload',
                      'Check your connection and try again, or paste an audio link instead.',
                    );
                    return;
                  }
                }

                if (imageUrl.isEmpty || audioUrl.isEmpty) {
                  setState(() => saving = false);
                  Get.snackbar(
                    'Cover and audio needed',
                    'Upload both files or paste a link for the cover image and the audio.',
                  );
                  return;
                }

                final song = SongModel(
                  id: id,
                  title: title,
                  artist: artist,
                  categoryId: categoryId,
                  bpm: bpmValue,
                  durationSec: parseDuration(durationC.text),
                  imageUrl: imageUrl,
                  audioUrl: audioUrl,
                  isActive: active,
                  createdAt: existing?.createdAt ?? now,
                );
                try {
                  await service.upsertSong(song);
                  if (existing == null) {
                    data.addSong(song);
                  } else {
                    data.updateSong(existing.id, song);
                  }
                  final catLabel = data.categoryName(categoryId);
                  await data.recordRecentActivity(
                    existing == null ? 'New song' : 'Song updated',
                    existing == null
                        ? 'Added “$title” by $artist in $catLabel.'
                        : 'Updates to “$title” by $artist ($catLabel) were saved.',
                    kind: existing == null ? 'song_added' : 'song_updated',
                  );
                  if (!context.mounted) return;
                  Navigator.pop(ctx);
                  deferredSnackbar(
                    existing == null
                        ? 'Song added successfully.'
                        : 'Song updated successfully.',
                    '',
                  );
                } catch (_) {
                  Get.snackbar(
                    'Couldn’t save song',
                    'Check your connection and try again. If the problem continues, contact support.',
                  );
                } finally {
                  if (context.mounted) {
                    setState(() => saving = false);
                  }
                }
              }

              final titleStyle =
                  Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ) ??
                  TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outline.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    existing == null ? 'Add song' : 'Edit song',
                                    style: titleStyle,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Metadata, category, and media upload.',
                                    style: Theme.of(ctx).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.35,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        SizedBox(height: AdminUi.sectionGap),
                        sectionLabel('Details', scheme),
                        AuthTextField(
                          label: 'Title',
                          placeholder: 'Song title',
                          leadingIcon: Icons.music_note_outlined,
                          controller: titleC,
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        AuthTextField(
                          label: 'Artist',
                          placeholder: 'Artist name',
                          leadingIcon: Icons.person_outline_rounded,
                          controller: artistC,
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: AppTextStyles.onboardingDescription
                                  .copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              // ignore: deprecated_member_use
                              value: categoryId,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 14,
                              ),
                              decoration: categoryDecoration(scheme),
                              items: [
                                for (final c in data.categories)
                                  DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                              ],
                              onChanged: (v) =>
                                  setState(() => categoryId = v ?? categoryId),
                            ),
                          ],
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AuthTextField(
                                label: 'BPM',
                                placeholder: '120',
                                leadingIcon: Icons.speed_rounded,
                                controller: bpmC,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AuthTextField(
                                label: 'Duration',
                                placeholder: 'mm:ss',
                                leadingIcon: Icons.timer_outlined,
                                controller: durationC,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AdminUi.sectionGap),
                        sectionLabel('Media', scheme),
                        AuthTextField(
                          label: 'Cover image URL',
                          placeholder: 'https://...',
                          leadingIcon: Icons.image_outlined,
                          controller: imageC,
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        SizedBox(
                          height: h,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  withData: true,
                                );
                              } catch (e) {
                                final msg = e.toString();
                                Get.snackbar(
                                  msg.contains('LateInitializationError')
                                      ? 'Can’t open file picker here'
                                      : 'Couldn’t open file picker',
                                  msg.contains('LateInitializationError')
                                      ? 'Paste a cover image link in the field above instead.'
                                      : 'Paste a cover image link in the field above, or try again.',
                                );
                                return;
                              }
                              if (result == null || result.files.isEmpty) {
                                return;
                              }
                              final file = result.files.first;
                              if (file.bytes == null) {
                                Get.snackbar(
                                  'Can’t use this image',
                                  'Try another file or paste an image link instead.',
                                );
                                return;
                              }
                              setState(() {
                                pickedImageFile = file;
                                pickedImageName = file.name;
                              });
                            },
                            style: outlineActionStyle(scheme),
                            icon: Icon(
                              Icons.image_outlined,
                              size: 20,
                              color: scheme.primary,
                            ),
                            label: Text(
                              pickedImageName ?? 'Choose image to upload',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        AuthTextField(
                          label: 'Audio URL',
                          placeholder: 'https://...',
                          leadingIcon: Icons.audio_file_outlined,
                          controller: audioC,
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        SizedBox(
                          height: h,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result;
                              try {
                                result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: const [
                                    'mp3',
                                    'wav',
                                    'aac',
                                    'm4a',
                                    'ogg',
                                  ],
                                  withData: true,
                                );
                              } catch (e) {
                                final msg = e.toString();
                                Get.snackbar(
                                  msg.contains('LateInitializationError')
                                      ? 'Can’t open file picker here'
                                      : 'Couldn’t open file picker',
                                  msg.contains('LateInitializationError')
                                      ? 'Paste an audio link in the field above instead.'
                                      : 'Paste an audio link in the field above, or try again.',
                                );
                                return;
                              }
                              if (result == null || result.files.isEmpty) {
                                return;
                              }
                              final file = result.files.first;
                              if (file.bytes == null) {
                                Get.snackbar(
                                  'Can’t use this audio file',
                                  'Try another file or paste an audio link instead.',
                                );
                                return;
                              }
                              setState(() {
                                pickedAudioFile = file;
                                pickedAudioName = file.name;
                              });
                            },
                            style: outlineActionStyle(scheme),
                            icon: Icon(
                              Icons.audio_file_outlined,
                              size: 20,
                              color: scheme.primary,
                            ),
                            label: Text(
                              pickedAudioName ?? 'Choose audio to upload',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: AdminUi.sectionGap),
                        sectionLabel('Publishing', scheme),
                        Material(
                          color: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            value: active,
                            onChanged: (v) => setState(() => active = v),
                            title: Text(
                              'Active',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              active
                                  ? 'Visible in listings'
                                  : 'Hidden from listings',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
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
                                  onPressed: () => Navigator.pop(ctx),
                                  style: outlineActionStyle(scheme),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: h,
                                child: FilledButton(
                                  onPressed: saving ? null : saveSong,
                                  style: filledActionStyle(),
                                  child: saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
