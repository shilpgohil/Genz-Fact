import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'session_media_library.dart';

Future<List<SessionFile>> pickBrowserMedia() async {
  final input = html.FileUploadInputElement()
    ..multiple = true
    ..accept = 'image/*,video/*';

  final done = Completer<List<html.File>?>();
  input.onChange.listen((_) {
    if (!done.isCompleted) done.complete(input.files);
  });
  late StreamSubscription<html.Event> focusSub;
  focusSub = html.window.onFocus.listen((_) {
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!done.isCompleted) done.complete(null);
    });
  });
  input.click();
  final files = await done.future;
  await focusSub.cancel();
  if (files == null || files.isEmpty) return const [];

  final session = <SessionFile>[];
  for (final file in files) {
    final converted = await _toSessionFile(file);
    if (converted != null) session.add(converted);
  }
  return session;
}

Future<SessionFile?> _toSessionFile(html.File file) async {
  final mime = file.type;
  final name = file.name;
  final isVideo = mime.startsWith('video/') || _isVideoName(name);
  final isImage = mime.startsWith('image/') || _isImageName(name);
  if (!isVideo && !isImage) return null;

  final objectUrl = html.Url.createObjectUrl(file);
  Uint8List bytes = Uint8List(0);
  int? width;
  int? height;
  if (isImage) {
    bytes = await _readBytes(file);
    final size = await _imageSize(bytes);
    width = size.$1;
    height = size.$2;
  }

  String? relativePath;
  try {
    final value = (file as dynamic).webkitRelativePath as String?;
    if (value != null && value.isNotEmpty) relativePath = value;
  } catch (_) {}

  return SessionFile(
    name: name,
    bytes: bytes,
    lastModified: DateTime.fromMillisecondsSinceEpoch(
      file.lastModified ?? DateTime.now().millisecondsSinceEpoch,
    ),
    mimeType: mime.isEmpty ? null : mime,
    relativePath: relativePath,
    width: width,
    height: height,
    objectUrl: objectUrl,
    sizeBytes: file.size,
  );
}

Future<Uint8List> _readBytes(html.File file) async {
  final reader = html.FileReader();
  final loaded = reader.onLoad.first;
  reader.readAsArrayBuffer(file);
  await loaded;
  final result = reader.result;
  if (result is ByteBuffer) return Uint8List.view(result);
  return Uint8List(0);
}

Future<(int, int)> _imageSize(Uint8List bytes) async {
  if (bytes.isEmpty) return (0, 0);
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    frame.image.dispose();
    return (width, height);
  } catch (_) {
    return (0, 0);
  }
}

bool _isVideoName(String name) {
  final lower = name.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.m4v') ||
      lower.endsWith('.webm');
}

bool _isImageName(String name) {
  final lower = name.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.heic') ||
      lower.endsWith('.heif') ||
      lower.endsWith('.bmp');
}
