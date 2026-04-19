import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Inline play/pause for a remote audio URL (e.g. after upload or pasted link).
class SongAudioPreviewBar extends StatefulWidget {
  const SongAudioPreviewBar({super.key, required this.url});

  final String url;

  @override
  State<SongAudioPreviewBar> createState() => _SongAudioPreviewBarState();
}

class _SongAudioPreviewBarState extends State<SongAudioPreviewBar> {
  late final AudioPlayer _player = AudioPlayer();
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  Future<void> _bind() async {
    final u = widget.url.trim();
    if (u.isEmpty) return;
    try {
      await _player.setUrl(u);
      if (mounted) {
        setState(() {
          _ready = true;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _ready = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant SongAudioPreviewBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _ready = false;
      _failed = false;
      _player.stop();
      _bind();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final u = widget.url.trim();
    if (u.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!_ready && !_failed) {
      return Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading audio preview…',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      );
    }
    if (_failed || !_ready) {
      return Text(
        'Couldn’t load audio for preview',
        style: TextStyle(color: scheme.error, fontSize: 13),
      );
    }
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      initialData: _player.playerState,
      builder: (context, snap) {
        final playing = snap.data?.playing ?? false;
        return Row(
          children: [
            IconButton.filledTonal(
              tooltip: playing ? 'Pause' : 'Play',
              onPressed: () async {
                if (playing) {
                  await _player.pause();
                } else {
                  if (_player.processingState == ProcessingState.completed) {
                    await _player.seek(Duration.zero);
                  }
                  await _player.play();
                }
              },
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Preview playback',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }
}
