import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instructor_beats_admin/core/admin_ui_constants.dart';
import 'package:instructor_beats_admin/core/deferred_snackbar.dart';
import 'package:instructor_beats_admin/data/admin_data_controller.dart';
import 'package:instructor_beats_admin/features/playlists/controllers/playlists_controller.dart';
import 'package:instructor_beats_admin/models/playlist_model.dart';

Future<void> showPlaylistSongsDialog(
  BuildContext context, {
  required PlaylistModel playlist,
}) async {
  final data = Get.find<AdminDataController>();
  final controller = Get.find<PlaylistsController>();
  if (data.songs.isEmpty) {
    await data.refreshSongsFromFirebase();
    if (!context.mounted) return;
  }

  final selectedSongIds = <String>[...playlist.songIds];
  final searchC = TextEditingController();
  final h = AdminUi.controlHeight;
  var saving = false;

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final scheme = Theme.of(dialogCtx).colorScheme;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(dialogCtx).height * 0.88,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> save() async {
                if (saving) return;
                setState(() => saving = true);
                final ok = await controller.updatePlaylistSongs(
                  playlist: playlist,
                  songIds: selectedSongIds,
                );
                if (ok) {
                  deferredSnackbar(
                    'Playlist songs updated',
                    '“${playlist.name}” now has ${selectedSongIds.length} song(s).',
                  );
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                }
                if (dialogCtx.mounted) {
                  setState(() => saving = false);
                }
              }

              final q = searchC.text.trim().toLowerCase();
              var songs = data.songs.toList();
              songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              if (q.isNotEmpty) {
                songs = songs
                    .where((s) =>
                        s.title.toLowerCase().contains(q) ||
                        s.artist.toLowerCase().contains(q))
                    .toList();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add songs: ${playlist.name}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: saving ? null : () => Navigator.pop(dialogCtx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select songs to include. Track count updates automatically.',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                    SizedBox(height: AdminUi.fieldGap),
                    TextField(
                      controller: searchC,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Search songs by title or artist',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${selectedSongIds.length} selected',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: songs.isEmpty
                          ? Center(
                              child: Text(
                                'No songs available yet. Add songs first.',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: songs.length,
                              itemBuilder: (context, i) {
                                final s = songs[i];
                                final checked = selectedSongIds.contains(s.id);
                                return CheckboxListTile(
                                  value: checked,
                                  onChanged: saving
                                      ? null
                                      : (v) {
                                          setState(() {
                                            if (v == true) {
                                              if (!selectedSongIds.contains(s.id)) {
                                                selectedSongIds.add(s.id);
                                              }
                                            } else {
                                              selectedSongIds.remove(s.id);
                                            }
                                          });
                                        },
                                  title: Text(
                                    s.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    s.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  dense: true,
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              },
                            ),
                    ),
                    SizedBox(height: AdminUi.sectionGap),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: OutlinedButton(
                              onPressed: saving ? null : () => Navigator.pop(dialogCtx),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: h,
                            child: FilledButton(
                              onPressed: saving ? null : save,
                              child: saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Save songs'),
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
