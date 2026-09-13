import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController? createVideoController({String? path, String? url}) {
  if (url != null && url.isNotEmpty) {
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }
  if (path == null || path.isEmpty) return null;
  return VideoPlayerController.file(File(path));
}
