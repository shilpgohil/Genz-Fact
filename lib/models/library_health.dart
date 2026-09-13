enum MediaCategoryKind {
  recent,
  favorites,
  videos,
  screenshots,
  large,
  bursts,
  portraits,
}

class MediaCategory {
  const MediaCategory({
    required this.kind,
    required this.title,
    required this.count,
    this.bytes,
    this.coverId,
  });

  final MediaCategoryKind kind;
  final String title;
  final int count;
  final int? bytes;
  final String? coverId;
}

class LibraryHealth {
  const LibraryHealth({
    required this.photoCount,
    required this.videoCount,
    required this.screenshotCount,
    required this.favoriteCount,
    required this.largeCount,
    required this.duplicateCandidateCount,
    required this.knownBytes,
    required this.sizedAssetCount,
    required this.totalCount,
    required this.recentCount,
  });

  final int photoCount;
  final int videoCount;
  final int screenshotCount;
  final int favoriteCount;
  final int largeCount;
  final int duplicateCandidateCount;
  final int knownBytes;
  final int sizedAssetCount;
  final int totalCount;
  final int recentCount;

  bool get sizesComplete => totalCount == 0 || sizedAssetCount >= totalCount;
}
