import 'package:luma/models/media_asset.dart';

MediaAsset sampleAsset({
  required String id,
  DateTime? createdAt,
  MediaKind kind = MediaKind.image,
  int width = 4000,
  int height = 3000,
  int? fileSizeBytes = 2 * 1024 * 1024,
  bool isFavorite = false,
  String? title,
  String? relativePath,
  int subtype = 0,
  int? perceptualHash,
  Duration duration = Duration.zero,
}) {
  return MediaAsset(
    id: id,
    kind: kind,
    createdAt: createdAt ?? DateTime(2025, 8, 18, 19, 30),
    width: width,
    height: height,
    fileSizeBytes: fileSizeBytes,
    isFavorite: isFavorite,
    title: title,
    relativePath: relativePath,
    subtype: subtype,
    perceptualHash: perceptualHash,
    duration: duration,
  );
}
