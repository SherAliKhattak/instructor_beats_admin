import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/videos/controllers/videos_controller.dart';
import 'package:instructor_beats_admin/models/video_model.dart';
import 'package:instructor_beats_admin/services/firebase_video_service.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';

Future<void> showVideoFormDialog(
  BuildContext context, {
  VideoModel? existing,
}) async {
  final controller = Get.find<VideosController>();
  final h = AdminUi.controlHeight;
  final titleC = TextEditingController(text: existing?.title ?? '');
  final descC = TextEditingController(text: existing?.description ?? '');
  final videoUrlC = TextEditingController(text: existing?.videoUrl ?? '');
  final thumbC = TextEditingController(text: existing?.thumbnailUrl ?? '');
  var published = existing?.isPublished ?? true;
  var selectedCategoryId = existing?.categoryId?.trim();
  if (selectedCategoryId?.isEmpty == true) {
    selectedCategoryId = null;
  }

  var saving = false;
  PlatformFile? pickedVideoFile;
  String? pickedVideoName;
  PlatformFile? pickedThumbFile;
  String? pickedThumbName;

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

  ButtonStyle pickFileStyle() => OutlinedButton.styleFrom(
        minimumSize: Size(0, h),
        maximumSize: Size(double.infinity, h),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: 0.9),
        ),
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
                if (saving) return;
                final title = titleC.text.trim();
                if (title.isEmpty) {
                  showAppSnackbar(
                    'Title needed',
                    'Please enter a title for this video.',
                  );
                  return;
                }

                saving = true;
                setDialogState(() {});

                final now = DateTime.now();
                final videoId = existing?.id ?? 'v_${now.millisecondsSinceEpoch}';
                final storage = Get.find<FirebaseVideoService>();

                var videoUrl = videoUrlC.text.trim();
                if (pickedVideoFile?.bytes != null) {
                  try {
                    videoUrl = await storage.uploadVideoFile(
                      videoId: videoId,
                      bytes: pickedVideoFile!.bytes!,
                      fileName: pickedVideoFile!.name,
                    );
                    if (dialogCtx.mounted) {
                      videoUrlC.text = videoUrl;
                    }
                  } catch (_) {
                    saving = false;
                    if (dialogCtx.mounted) setDialogState(() {});
                    showAppSnackbar(
                      'Video didn’t upload',
                      'Check your connection and try again, or paste a video link instead.',
                    );
                    return;
                  }
                }

                if (videoUrl.isEmpty) {
                  saving = false;
                  if (dialogCtx.mounted) setDialogState(() {});
                  showAppSnackbar(
                    'Video required',
                    'Choose a video file from your device or paste a playable link.',
                  );
                  return;
                }

                var thumb = thumbC.text.trim();
                if (pickedThumbFile?.bytes != null) {
                  try {
                    thumb = await storage.uploadThumbnail(
                      videoId: videoId,
                      bytes: pickedThumbFile!.bytes!,
                      fileName: pickedThumbFile!.name,
                    );
                    if (dialogCtx.mounted) {
                      thumbC.text = thumb;
                    }
                  } catch (_) {
                    saving = false;
                    if (dialogCtx.mounted) setDialogState(() {});
                    showAppSnackbar(
                      'Thumbnail didn’t upload',
                      'Check your connection and try again, or paste an image link instead.',
                    );
                    return;
                  }
                }

                final desc = descC.text.trim();

                final video = VideoModel(
                  id: videoId,
                  title: title,
                  description: desc.isEmpty ? null : desc,
                  videoUrl: videoUrl,
                  thumbnailUrl: thumb.isEmpty ? null : thumb,
                  durationSec: existing?.durationSec,
                  categoryId: selectedCategoryId,
                  isPublished: published,
                  createdAt: existing?.createdAt ?? now,
                );

                final saved = existing == null
                    ? await controller.addVideo(video)
                    : await controller.replaceVideo(existing.id, video);
                saving = false;
                if (dialogCtx.mounted) setDialogState(() {});

                if (!saved) return;

                final data = Get.find<AdminDataController>();
                await data.recordRecentActivity(
                  existing == null ? 'New video' : 'Video updated',
                  existing == null
                      ? '“$title” was added to your video library.'
                      : 'Your changes to “$title” were saved.',
                  kind: existing == null ? 'video_added' : 'video_updated',
                );
                deferredSnackbar(
                  existing == null ? 'Video saved' : 'Changes saved',
                  existing == null
                      ? '“$title” is in your video list.'
                      : 'Updates to “$title” are saved.',
                );
                if (dialogCtx.mounted) close();
              }

              Future<void> pickVideo() async {
                FilePickerResult? result;
                try {
                  result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: const [
                      'mp4',
                      'mov',
                      'webm',
                      'm4v',
                      'mkv',
                      'avi',
                      'mpeg',
                      'mpg',
                    ],
                    withData: true,
                  );
                } catch (e) {
                  final msg = e.toString();
                  showAppSnackbar(
                    msg.contains('LateInitializationError')
                        ? 'Can’t open file picker here'
                        : 'Couldn’t open file picker',
                    msg.contains('LateInitializationError')
                        ? 'Paste a video link in the field below instead.'
                        : 'Paste a video link below, or try again.',
                  );
                  return;
                }
                if (result == null || result.files.isEmpty) return;
                final file = result.files.first;
                if (file.bytes == null) {
                  showAppSnackbar(
                    'Can’t use this video',
                    'Try another file or paste a video link instead.',
                  );
                  return;
                }
                setDialogState(() {
                  pickedVideoFile = file;
                  pickedVideoName = file.name;
                });
              }

              Future<void> pickThumbnail() async {
                FilePickerResult? result;
                try {
                  result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                } catch (e) {
                  final msg = e.toString();
                  showAppSnackbar(
                    msg.contains('LateInitializationError')
                        ? 'Can’t open file picker here'
                        : 'Couldn’t open file picker',
                    msg.contains('LateInitializationError')
                        ? 'Paste a thumbnail link in the field below instead.'
                        : 'Paste an image link below, or try again.',
                  );
                  return;
                }
                if (result == null || result.files.isEmpty) return;
                final file = result.files.first;
                if (file.bytes == null) {
                  showAppSnackbar(
                    'Can’t use this image',
                    'Try another file or paste a thumbnail link instead.',
                  );
                  return;
                }
                setDialogState(() {
                  pickedThumbFile = file;
                  pickedThumbName = file.name;
                });
              }

              Widget fieldLabel(String text) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    text.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                );
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
                                existing == null ? 'Add video' : 'Edit video',
                                style: titleStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Upload a video and optional thumbnail from your computer, or paste URLs.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
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
                          onPressed: saving ? null : close,
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
                              label: 'Title',
                              placeholder: 'Video title',
                              leadingIcon: Icons.title_rounded,
                              controller: titleC,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Description',
                              placeholder: 'Short summary (optional)',
                              leadingIcon: Icons.notes_outlined,
                              controller: descC,
                            ),
                            SizedBox(height: AdminUi.sectionGap),
                            fieldLabel('Video file'),
                            SizedBox(
                              height: h,
                              child: OutlinedButton.icon(
                                onPressed: saving ? null : pickVideo,
                                style: pickFileStyle(),
                                icon: Icon(
                                  Icons.video_file_outlined,
                                  size: 20,
                                  color: scheme.primary,
                                ),
                                label: Text(
                                  pickedVideoName ?? 'Choose video from device',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (pickedVideoName != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Selected: $pickedVideoName',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Video URL (optional)',
                              placeholder:
                                  'https://… if not uploading a file',
                              leadingIcon: Icons.link_rounded,
                              controller: videoUrlC,
                            ),
                            SizedBox(height: AdminUi.sectionGap),
                            fieldLabel('Thumbnail'),
                            SizedBox(
                              height: h,
                              child: OutlinedButton.icon(
                                onPressed: saving ? null : pickThumbnail,
                                style: pickFileStyle(),
                                icon: Icon(
                                  Icons.image_outlined,
                                  size: 20,
                                  color: scheme.primary,
                                ),
                                label: Text(
                                  pickedThumbName ??
                                      'Choose thumbnail image (optional)',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (pickedThumbName != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Selected: $pickedThumbName',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            SizedBox(height: AdminUi.fieldGap),
                            AuthTextField(
                              label: 'Thumbnail URL (optional)',
                              placeholder: 'https://… if not uploading',
                              leadingIcon: Icons.image_outlined,
                              controller: thumbC,
                            ),
                            SizedBox(height: AdminUi.fieldGap),
                            Obx(() {
                              final adminData =
                                  Get.find<AdminDataController>();
                              final cats = adminData.videoCategories.toList();
                              final ids = cats.map((e) => e.id).toSet();
                              final value =
                                  selectedCategoryId != null &&
                                          ids.contains(selectedCategoryId)
                                      ? selectedCategoryId
                                      : null;
                              return DropdownButtonFormField<String?>(
                                key: ValueKey<String?>(value),
                                initialValue: value,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Video category',
                                  prefixIcon: const Icon(
                                    Icons.video_settings_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('None'),
                                  ),
                                  ...cats.map(
                                    (c) => DropdownMenuItem<String?>(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  ),
                                ],
                                onChanged: saving
                                    ? null
                                    : (v) {
                                        setDialogState(
                                          () => selectedCategoryId = v,
                                        );
                                      },
                              );
                            }),
                            SizedBox(height: AdminUi.fieldGap),
                            Material(
                              color: scheme.surfaceContainerHighest.withValues(
                                alpha: 0.45,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: SwitchListTile.adaptive(
                                value: published,
                                onChanged: saving
                                    ? null
                                    : (v) =>
                                        setDialogState(() => published = v),
                                title: const Text('Published'),
                                subtitle: const Text(
                                  'When off, the video stays hidden from the app.',
                                ),
                                activeTrackColor: AppColors.primary
                                    .withValues(alpha: 0.55),
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
                              onPressed: saving ? null : close,
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
                              onPressed: saving ? null : saveAndClose,
                              style: filledStyle(),
                              child: saving
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onPrimary,
                                      ),
                                    )
                                  : Text(existing == null ? 'Add' : 'Save'),
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
