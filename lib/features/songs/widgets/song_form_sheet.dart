import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart'
    show deferredSnackbar, showAppSnackbar;
import 'package:instructor_beats_admin/core/widgets/app_text_field.dart';
import 'package:instructor_beats_admin/core/widgets/storage_or_network_image.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/songs/widgets/song_audio_preview.dart';
import 'package:instructor_beats_admin/models/song_model.dart';
import 'package:instructor_beats_admin/services/firebase_song_service.dart';
import 'package:instructor_beats_admin/theme/app_text_styles.dart';

Future<void> showSongFormSheet(
  BuildContext context, {
  SongModel? existing,
}) async {
  final h = AdminUi.controlHeight;
  final data = Get.find<AdminDataController>();
  if (data.categories.isEmpty) {
    showAppSnackbar(
      'Add a category first',
      'Create at least one category, then you can add songs to it.',
    );
    return;
  }

  final draftSongId =
      existing?.id ?? 's_${DateTime.now().millisecondsSinceEpoch}';

  final selectedCategoryIds = <String>{};
  if (existing != null) {
    final valid = existing.categoryIds
        .where((id) => data.categories.any((c) => c.id == id))
        .toSet();
    selectedCategoryIds.addAll(
      valid.isNotEmpty ? valid : {data.categories.first.id},
    );
  } else {
    selectedCategoryIds.add(data.categories.first.id);
  }

  final selectedPlaylistIds = <String>{
    if (existing != null)
      ...existing.playlistIds.where(
        (id) => data.playlists.any((p) => p.id == id),
      ),
  };

  final titleC = TextEditingController(text: existing?.title ?? '');
  final artistC = TextEditingController(text: existing?.artist ?? '');
  final bpmC = TextEditingController(
    text: existing != null ? '${existing.bpm}' : '128',
  );
  final imageC = TextEditingController(text: existing?.imageUrl ?? '');
  final audioC = TextEditingController(text: existing?.audioUrl ?? '');
  final categorySearchC = TextEditingController();
  final playlistSearchC = TextEditingController();
  var active = existing?.isActive ?? true;
  var saving = false;
  var uploadingCover = false;
  var uploadingAudio = false;
  String? pickedImageName;
  String? pickedAudioName;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
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

              Future<void> saveSong() async {
                if (saving) return;
                setState(() => saving = true);
                final now = DateTime.now();
                final service = Get.find<FirebaseSongService>();
                final id = existing?.id ?? draftSongId;

                final title = titleC.text.trim();
                final artist = artistC.text.trim();
                if (title.isEmpty || artist.isEmpty) {
                  setState(() => saving = false);
                  showAppSnackbar(
                    'Title and artist needed',
                    'Please fill in both the song title and artist name.',
                  );
                  return;
                }

                if (selectedCategoryIds.isEmpty) {
                  setState(() => saving = false);
                  showAppSnackbar(
                    'Pick at least one category',
                    'Choose one or more categories this song belongs to.',
                  );
                  return;
                }

                final bpmValue = int.tryParse(bpmC.text.trim());
                if (bpmValue == null || bpmValue <= 0) {
                  setState(() => saving = false);
                  showAppSnackbar(
                    'Check the tempo (BPM)',
                    'Enter beats per minute as a positive number (e.g. 120).',
                  );
                  return;
                }

                final imageUrl = imageC.text.trim();
                final audioUrl = audioC.text.trim();

                if (imageUrl.isEmpty || audioUrl.isEmpty) {
                  setState(() => saving = false);
                  showAppSnackbar(
                    'Cover and audio needed',
                    'Upload both files or paste a link for the cover image and the audio.',
                  );
                  return;
                }

                final categoryIds = selectedCategoryIds.toList()..sort();
                final playlistIds = selectedPlaylistIds.toList()..sort();

                final song = SongModel(
                  id: id,
                  title: title,
                  artist: artist,
                  categoryIds: categoryIds,
                  playlistIds: playlistIds,
                  bpm: bpmValue,
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
                  final catLabel = data.categoryNamesLabel(categoryIds);
                  final plLabel = data.playlistNamesLabel(playlistIds);
                  final plSuffix = playlistIds.isEmpty
                      ? ''
                      : ' Playlists: $plLabel.';
                  await data.recordRecentActivity(
                    existing == null ? 'New song' : 'Song updated',
                    existing == null
                        ? 'Added “$title” by $artist — categories: $catLabel.$plSuffix'
                        : 'Updates to “$title” by $artist — categories: $catLabel.$plSuffix',
                    kind: existing == null ? 'song_added' : 'song_updated',
                  );
                  if (!context.mounted) return;
                  Navigator.pop(ctx);
                  deferredSnackbar(
                    existing == null ? 'Song saved' : 'Song updated',
                    existing == null
                        ? '“$title” by $artist is in the catalog.'
                        : 'Your edits to “$title” are saved.',
                  );
                } catch (_) {
                  showAppSnackbar(
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

              void toggleCategory(String id, bool selected) {
                if (!selected && selectedCategoryIds.length <= 1) {
                  showAppSnackbar(
                    'Keep one category',
                    'A song must stay in at least one category.',
                  );
                  return;
                }
                setState(() {
                  if (selected) {
                    selectedCategoryIds.add(id);
                  } else {
                    selectedCategoryIds.remove(id);
                  }
                });
              }

              void togglePlaylist(String id, bool selected) {
                setState(() {
                  if (selected) {
                    selectedPlaylistIds.add(id);
                  } else {
                    selectedPlaylistIds.remove(id);
                  }
                });
              }

              final hasCoverPreview = imageC.text.trim().isNotEmpty;
              final hasAudioPreview = audioC.text.trim().isNotEmpty;

              final catQ = categorySearchC.text.trim().toLowerCase();
              final filteredCategories = catQ.isEmpty
                  ? data.categories.toList()
                  : data.categories
                        .where((c) => c.name.toLowerCase().contains(catQ))
                        .toList();

              final plQ = playlistSearchC.text.trim().toLowerCase();
              final filteredPlaylists = plQ.isEmpty
                  ? data.playlists.toList()
                  : data.playlists.where((p) {
                      final name = p.name.toLowerCase().contains(plQ);
                      final desc =
                          p.description?.toLowerCase().contains(plQ) ?? false;
                      return name || desc;
                    }).toList();

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
                                    'Metadata, categories, playlists, and media.',
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
                              'Categories',
                              style: AppTextStyles.onboardingDescription
                                  .copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: categorySearchC,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search categories',
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                                filled: true,
                                fillColor: scheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: scheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: scheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: scheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (filteredCategories.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Text(
                                  'No categories match your search.',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 40,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: IconTheme(
                                    data: const IconThemeData(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < filteredCategories.length;
                                          i++
                                        ) ...[
                                          if (i > 0) const SizedBox(width: 8),
                                          _songFormFilterChip(
                                            scheme: scheme,
                                            label: filteredCategories[i].name,
                                            selected: selectedCategoryIds
                                                .contains(
                                                  filteredCategories[i].id,
                                                ),
                                            onSelected: (sel) => toggleCategory(
                                              filteredCategories[i].id,
                                              sel,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (data.playlists.isNotEmpty) ...[
                          SizedBox(height: AdminUi.fieldGap),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Playlists',
                                style: AppTextStyles.onboardingDescription
                                    .copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: playlistSearchC,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search playlists by name or note',
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  filled: true,
                                  fillColor: scheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: scheme.outline.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: scheme.outline.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: scheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (filteredPlaylists.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    'No playlists match your search.',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 40,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: IconTheme(
                                      data: const IconThemeData(
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          for (
                                            var i = 0;
                                            i < filteredPlaylists.length;
                                            i++
                                          ) ...[
                                            if (i > 0) const SizedBox(width: 8),
                                            _songFormFilterChip(
                                              scheme: scheme,
                                              label: filteredPlaylists[i].name,
                                              selected: selectedPlaylistIds
                                                  .contains(
                                                    filteredPlaylists[i].id,
                                                  ),
                                              onSelected: (sel) =>
                                                  togglePlaylist(
                                                    filteredPlaylists[i].id,
                                                    sel,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        SizedBox(height: AdminUi.fieldGap),
                        AuthTextField(
                          label: 'BPM',
                          placeholder: '120',
                          leadingIcon: Icons.speed_rounded,
                          controller: bpmC,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: AdminUi.sectionGap),
                        sectionLabel('Media', scheme),
                        AuthTextField(
                          label: 'Cover image URL',
                          placeholder: 'https://...',
                          leadingIcon: Icons.image_outlined,
                          controller: imageC,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        SizedBox(
                          height: h,
                          child: OutlinedButton.icon(
                            onPressed: uploadingCover
                                ? null
                                : () async {
                                    FilePickerResult? result;
                                    try {
                                      result = await FilePicker.platform
                                          .pickFiles(
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
                                            ? 'Paste a cover image link in the field above instead.'
                                            : 'Paste a cover image link in the field above, or try again.',
                                      );
                                      return;
                                    }
                                    if (result == null ||
                                        result.files.isEmpty) {
                                      return;
                                    }
                                    final file = result.files.first;
                                    if (file.bytes == null) {
                                      showAppSnackbar(
                                        'Can’t use this image',
                                        'Try another file or paste an image link instead.',
                                      );
                                      return;
                                    }
                                    setState(() {
                                      uploadingCover = true;
                                      pickedImageName = file.name;
                                    });
                                    final service =
                                        Get.find<FirebaseSongService>();
                                    try {
                                      final url = await service.uploadImage(
                                        songId: draftSongId,
                                        bytes: file.bytes!,
                                        fileName: file.name,
                                      );
                                      imageC.text = url;
                                      setState(() {
                                        uploadingCover = false;
                                      });
                                    } catch (_) {
                                      setState(() => uploadingCover = false);
                                      showAppSnackbar(
                                        'Cover didn’t upload',
                                        'Check your connection and try again, or paste a link.',
                                      );
                                    }
                                  },
                            style: outlineActionStyle(scheme),
                            icon: uploadingCover
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: scheme.primary,
                                  ),
                            label: Text(
                              uploadingCover
                                  ? 'Uploading…'
                                  : (pickedImageName ??
                                        'Choose image to upload'),
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
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: AdminUi.fieldGap),
                        SizedBox(
                          height: h,
                          child: OutlinedButton.icon(
                            onPressed: uploadingAudio
                                ? null
                                : () async {
                                    FilePickerResult? result;
                                    try {
                                      result = await FilePicker.platform
                                          .pickFiles(
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
                                      showAppSnackbar(
                                        msg.contains('LateInitializationError')
                                            ? 'Can’t open file picker here'
                                            : 'Couldn’t open file picker',
                                        msg.contains('LateInitializationError')
                                            ? 'Paste an audio link in the field above instead.'
                                            : 'Paste an audio link in the field above, or try again.',
                                      );
                                      return;
                                    }
                                    if (result == null ||
                                        result.files.isEmpty) {
                                      return;
                                    }
                                    final file = result.files.first;
                                    if (file.bytes == null) {
                                      showAppSnackbar(
                                        'Can’t use this audio file',
                                        'Try another file or paste an audio link instead.',
                                      );
                                      return;
                                    }
                                    setState(() {
                                      uploadingAudio = true;
                                      pickedAudioName = file.name;
                                    });
                                    final service =
                                        Get.find<FirebaseSongService>();
                                    try {
                                      final url = await service.uploadAudio(
                                        songId: draftSongId,
                                        bytes: file.bytes!,
                                        fileName: file.name,
                                      );
                                      audioC.text = url;
                                      setState(() {
                                        uploadingAudio = false;
                                      });
                                    } catch (_) {
                                      setState(() => uploadingAudio = false);
                                      showAppSnackbar(
                                        'Audio didn’t upload',
                                        'Check your connection and try again, or paste a link.',
                                      );
                                    }
                                  },
                            style: outlineActionStyle(scheme),
                            icon: uploadingAudio
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.audio_file_outlined,
                                    size: 20,
                                    color: scheme.primary,
                                  ),
                            label: Text(
                              uploadingAudio
                                  ? 'Uploading…'
                                  : (pickedAudioName ??
                                        'Choose audio to upload'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: AdminUi.sectionGap),
                        sectionLabel('Preview', scheme),
                        if (!hasCoverPreview && !hasAudioPreview)
                          Text(
                            'Add cover and audio (upload or URL) to preview them here.',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          )
                        else ...[
                          if (hasCoverPreview)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: StorageOrNetworkImage(
                                    url: imageC.text.trim(),
                                    width: 120,
                                    height: 120,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Cover',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Confirm artwork looks correct before saving.',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (hasCoverPreview && hasAudioPreview)
                            const SizedBox(height: 12),
                          if (hasAudioPreview) ...[
                            Text(
                              'Audio',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SongAudioPreviewBar(url: audioC.text.trim()),
                          ],
                        ],
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

Widget _songFormFilterChip({
  required ColorScheme scheme,
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  return FilterChip(
    label: Text(
      label,
      style: TextStyle(
        color: selected ? Colors.white : scheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    selected: selected,
    onSelected: onSelected,
    showCheckmark: true,
    checkmarkColor: Colors.white,
    selectedColor: scheme.primary,
    backgroundColor: scheme.surfaceContainerHighest,
    side: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    labelPadding: const EdgeInsets.only(left: 2, right: 6),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
