import '../core/theme/luma_tokens.dart';
import '../models/library_health.dart';
import '../models/media_asset.dart';

List<MediaAsset> recentAssets(
  List<MediaAsset> assets, {
  DateTime? now,
  int days = LumaTokens.recentDays,
}) {
  final clock = now ?? DateTime.now();
  final start = clock.subtract(Duration(days: days));
  return assets.where((a) => !a.createdAt.isBefore(start)).toList();
}

List<MediaAsset> favoriteAssets(List<MediaAsset> assets) =>
    assets.where((a) => a.isFavorite).toList();

List<MediaAsset> videoAssets(List<MediaAsset> assets) =>
    assets.where((a) => a.isVideo).toList();

List<MediaAsset> screenshotAssets(List<MediaAsset> assets) =>
    assets.where((a) => a.isScreenshot).toList();

List<MediaAsset> largeAssets(List<MediaAsset> assets) =>
    assets.where((a) => a.isLargeImage || a.isLargeVideo).toList();

List<MediaAsset> portraitLikeAssets(List<MediaAsset> assets) =>
    assets.where((a) => a.isPortraitLike).toList();

/// Burst-like: 3+ captures within [LumaTokens.burstGap] of their neighbor.
List<List<MediaAsset>> burstSequences(List<MediaAsset> assets) {
  if (assets.length < 3) return const [];
  final sorted = [...assets]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final sequences = <List<MediaAsset>>[];
  var current = <MediaAsset>[sorted.first];
  for (var i = 1; i < sorted.length; i++) {
    final delta = sorted[i].createdAt.difference(current.last.createdAt);
    if (delta <= LumaTokens.burstGap && delta >= Duration.zero) {
      current.add(sorted[i]);
    } else {
      if (current.length >= 3) sequences.add(current);
      current = [sorted[i]];
    }
  }
  if (current.length >= 3) sequences.add(current);
  return sequences;
}

List<MediaAsset> burstAssets(List<MediaAsset> assets) {
  final ids = <String>{};
  final out = <MediaAsset>[];
  for (final seq in burstSequences(assets)) {
    for (final asset in seq) {
      if (ids.add(asset.id)) out.add(asset);
    }
  }
  return out;
}

List<MediaCategory> visibleCategories(
  List<MediaAsset> assets, {
  DateTime? now,
}) {
  final list = <MediaCategory>[];
  void add(MediaCategoryKind kind, String title, List<MediaAsset> items) {
    if (items.isEmpty) return;
    var known = 0;
    var anySize = false;
    for (final item in items) {
      if (item.fileSizeBytes != null) {
        anySize = true;
        known += item.fileSizeBytes!;
      }
    }
    list.add(
      MediaCategory(
        kind: kind,
        title: title,
        count: items.length,
        bytes: anySize ? known : null,
        coverId: items.first.id,
      ),
    );
  }

  add(
    MediaCategoryKind.recent,
    'Recently added',
    recentAssets(assets, now: now),
  );
  add(MediaCategoryKind.favorites, 'Favorites', favoriteAssets(assets));
  add(MediaCategoryKind.videos, 'Videos', videoAssets(assets));
  add(MediaCategoryKind.screenshots, 'Screenshots', screenshotAssets(assets));
  add(MediaCategoryKind.large, 'Large files', largeAssets(assets));
  add(MediaCategoryKind.bursts, 'Burst-like', burstAssets(assets));
  add(MediaCategoryKind.portraits, 'Portrait-like', portraitLikeAssets(assets));
  return list;
}

List<MediaAsset> assetsForCategory(
  List<MediaAsset> assets,
  MediaCategoryKind kind, {
  DateTime? now,
}) {
  switch (kind) {
    case MediaCategoryKind.recent:
      return recentAssets(assets, now: now);
    case MediaCategoryKind.favorites:
      return favoriteAssets(assets);
    case MediaCategoryKind.videos:
      return videoAssets(assets);
    case MediaCategoryKind.screenshots:
      return screenshotAssets(assets);
    case MediaCategoryKind.large:
      return largeAssets(assets);
    case MediaCategoryKind.bursts:
      return burstAssets(assets);
    case MediaCategoryKind.portraits:
      return portraitLikeAssets(assets);
  }
}

LibraryHealth buildHealth(
  List<MediaAsset> assets, {
  DateTime? now,
  int duplicateCandidateCount = 0,
}) {
  var photos = 0;
  var videos = 0;
  var shots = 0;
  var favs = 0;
  var large = 0;
  var bytes = 0;
  var sized = 0;
  for (final asset in assets) {
    if (asset.isVideo) {
      videos++;
    } else if (asset.isImage) {
      photos++;
    }
    if (asset.isScreenshot) shots++;
    if (asset.isFavorite) favs++;
    if (asset.isLargeImage || asset.isLargeVideo) large++;
    if (asset.fileSizeBytes != null) {
      sized++;
      bytes += asset.fileSizeBytes!;
    }
  }
  return LibraryHealth(
    photoCount: photos,
    videoCount: videos,
    screenshotCount: shots,
    favoriteCount: favs,
    largeCount: large,
    duplicateCandidateCount: duplicateCandidateCount,
    knownBytes: bytes,
    sizedAssetCount: sized,
    totalCount: assets.length,
    recentCount: recentAssets(assets, now: now).length,
  );
}
