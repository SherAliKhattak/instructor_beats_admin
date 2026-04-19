import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instructor_beats_admin/core/image_url.dart';

/// True for URLs that should try the Firebase Storage SDK before network HTML/img.
bool looksLikeFirebaseStorageUrl(String url) {
  final t = url.trim().toLowerCase();
  if (t.isEmpty) return false;
  if (t.startsWith('gs://')) return true;
  if (t.contains('firebasestorage.googleapis.com')) return true;
  if (t.contains('storage.googleapis.com')) return true;
  return false;
}

/// Parses `https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encodedPath}?...`
/// when [Reference.refFromURL] fails (encoding / edge cases).
Reference? referenceFromFirebaseV0HttpUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  if (!uri.host.toLowerCase().contains('firebasestorage.googleapis.com')) {
    return null;
  }
  final match = RegExp(r'^/v0/b/([^/]+)/o/(.+)$').firstMatch(uri.path);
  if (match == null) return null;
  final bucketId = match.group(1)!;
  final encodedObject = match.group(2)!;
  final objectPath = Uri.decodeComponent(encodedObject.replaceAll('+', '%20'));
  try {
    return FirebaseStorage.instanceFor(bucket: 'gs://$bucketId').ref(objectPath);
  } catch (_) {
    return null;
  }
}

Future<Uint8List?> _tryLoadFirebaseBytes(String url) async {
  final trimmed = url.trim();
  try {
    final ref = FirebaseStorage.instance.refFromURL(trimmed);
    final data = await ref.getData(15 * 1024 * 1024);
    if (data != null && data.isNotEmpty) return data;
  } catch (_) {}
  final alt = referenceFromFirebaseV0HttpUrl(trimmed);
  if (alt != null) {
    try {
      final data = await alt.getData(15 * 1024 * 1024);
      if (data != null && data.isNotEmpty) return data;
    } catch (_) {}
  }
  return null;
}

/// Tries [Reference.getData] for Firebase / GCS URLs, then [Image.network] with
/// [WebHtmlElementStrategy.prefer] so Flutter web uses an HTML &lt;img&gt; (avoids CORS
/// on fetch-based decoding).
class StorageOrNetworkImage extends StatefulWidget {
  const StorageOrNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  @override
  State<StorageOrNetworkImage> createState() => _StorageOrNetworkImageState();
}

class _StorageOrNetworkImageState extends State<StorageOrNetworkImage> {
  Uint8List? _bytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startLoad();
  }

  @override
  void didUpdateWidget(covariant StorageOrNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = null;
      _loading = false;
      _startLoad();
    }
  }

  Future<void> _startLoad() async {
    final url = normalizeImageUrl(widget.url);
    if (url.isEmpty) return;

    if (!looksLikeFirebaseStorageUrl(url)) {
      return;
    }

    setState(() => _loading = true);
    final data = await _tryLoadFirebaseBytes(url);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _bytes = data;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = false);
  }

  Widget _error(BuildContext context) {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final url = normalizeImageUrl(widget.url);
    if (url.isEmpty) {
      return _error(context);
    }

    if (_bytes != null) {
      Widget img = Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _error(context),
      );
      if (widget.borderRadius != null) {
        img = ClipRRect(borderRadius: widget.borderRadius!, child: img);
      }
      return img;
    }

    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Web: prefer HTML <img> to avoid CORS failures with fetch/CanvasKit.
    Widget net = Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (context, error, stackTrace) => _error(context),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
    );
    if (widget.borderRadius != null) {
      net = ClipRRect(borderRadius: widget.borderRadius!, child: net);
    }
    return net;
  }
}
