import 'media_asset.dart';

class MediaMoment {
  const MediaMoment({
    required this.id,
    required this.title,
    required this.assets,
    required this.start,
    required this.end,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<MediaAsset> assets;
  final DateTime start;
  final DateTime end;

  int get count => assets.length;
  MediaAsset? get hero => assets.isEmpty ? null : assets.first;
}
