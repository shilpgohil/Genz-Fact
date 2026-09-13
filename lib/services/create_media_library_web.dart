import 'browser_file_picker_web.dart';
import 'media_library.dart';
import 'session_media_library.dart';

MediaLibrary createMediaLibrary() {
  return SessionMediaLibrary(pickFiles: pickBrowserMedia);
}
