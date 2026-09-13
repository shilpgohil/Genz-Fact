import 'media_asset.dart';

class DateSection {
  const DateSection({required this.date, required this.assets});

  /// Date at local midnight.
  final DateTime date;
  final List<MediaAsset> assets;
}

enum GalleryRowKind { header, photos }

class GalleryRow {
  const GalleryRow.header(this.date)
    : kind = GalleryRowKind.header,
      assets = const [];

  const GalleryRow.photos(this.assets)
    : kind = GalleryRowKind.photos,
      date = null;

  final GalleryRowKind kind;
  final DateTime? date;
  final List<MediaAsset> assets;
}
