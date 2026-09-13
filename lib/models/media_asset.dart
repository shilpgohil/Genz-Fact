enum MediaKind { image, video, other }

/// iOS PHAssetMediaSubtype bits we actually use.
abstract final class MediaSubtype {
  static const int screenshot = 1 << 2;
  static const int livePhoto = 1 << 3;
  static const int depthEffect = 1 << 4;
}

class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.width,
    required this.height,
    this.modifiedAt,
    this.duration = Duration.zero,
    this.fileSizeBytes,
    this.isFavorite = false,
    this.title,
    this.mimeType,
    this.relativePath,
    this.latitude,
    this.longitude,
    this.subtype = 0,
    this.perceptualHash,
  });

  final String id;
  final MediaKind kind;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final int width;
  final int height;
  final Duration duration;
  final int? fileSizeBytes;
  final bool isFavorite;
  final String? title;
  final String? mimeType;
  final String? relativePath;
  final double? latitude;
  final double? longitude;
  final int subtype;

  /// Optional 64-bit dHash. Present after a user-initiated similar-photo scan
  /// or in tests. Never invent a hash.
  final int? perceptualHash;

  bool get isVideo => kind == MediaKind.video;
  bool get isImage => kind == MediaKind.image;
  bool get isLivePhoto => subtype & MediaSubtype.livePhoto != 0;
  bool get isPortraitLike => subtype & MediaSubtype.depthEffect != 0;
  bool get hasLocation => latitude != null && longitude != null;
  bool get isLargeImage =>
      isImage && fileSizeBytes != null && fileSizeBytes! >= 8 * 1024 * 1024;
  bool get isLargeVideo =>
      isVideo && fileSizeBytes != null && fileSizeBytes! >= 50 * 1024 * 1024;

  bool get isScreenshot {
    if (subtype & MediaSubtype.screenshot != 0) return true;
    final blob = '${title ?? ''} ${relativePath ?? ''} ${mimeType ?? ''}'
        .toLowerCase();
    return blob.contains('screenshot') || blob.contains('screen_shot');
  }

  MediaAsset copyWith({
    MediaKind? kind,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? width,
    int? height,
    Duration? duration,
    int? fileSizeBytes,
    bool? isFavorite,
    String? title,
    String? mimeType,
    String? relativePath,
    double? latitude,
    double? longitude,
    int? subtype,
    int? perceptualHash,
    bool clearFileSize = false,
  }) {
    return MediaAsset(
      id: id,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      fileSizeBytes: clearFileSize
          ? null
          : (fileSizeBytes ?? this.fileSizeBytes),
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
      mimeType: mimeType ?? this.mimeType,
      relativePath: relativePath ?? this.relativePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      subtype: subtype ?? this.subtype,
      perceptualHash: perceptualHash ?? this.perceptualHash,
    );
  }
}
