import 'package:video_player/video_player.dart';

VideoPlayerController? createVideoController({String? path, String? url}) {
  if (url == null || url.isEmpty) return null;
  return VideoPlayerController.networkUrl(Uri.parse(url));
}
