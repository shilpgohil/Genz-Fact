import '../models/app_models.dart';
import '../models/media_album.dart';
import '../models/media_asset.dart';

const _monthNames = <String, int>{
  'january': 1,
  'jan': 1,
  'february': 2,
  'feb': 2,
  'march': 3,
  'mar': 3,
  'april': 4,
  'apr': 4,
  'may': 5,
  'june': 6,
  'jun': 6,
  'july': 7,
  'jul': 7,
  'august': 8,
  'aug': 8,
  'september': 9,
  'sep': 9,
  'sept': 9,
  'october': 10,
  'oct': 10,
  'november': 11,
  'nov': 11,
  'december': 12,
  'dec': 12,
};

/// Parses a metadata query. Unrecognized tokens are kept so the UI can say
/// we don't understand them — never pretend to run semantic image search.
SearchIntent parseSearchQuery(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return SearchIntent(raw: raw);

  final tokens = trimmed.toLowerCase().split(RegExp(r'\s+'));
  int? year;
  int? month;
  int? day;
  int? relativeDays;
  var relativeSingleDay = false;
  MediaKind? kind;
  var screenshotsOnly = false;
  var favoritesOnly = false;
  var largeOnly = false;
  final leftover = <String>[];

  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i].replaceAll(RegExp(r'[^\w]'), '');
    if (token.isEmpty) continue;

    if (token == 'yesterday') {
      relativeDays = 1;
      relativeSingleDay = true;
      continue;
    }
    if (token == 'today') {
      relativeDays = 0;
      relativeSingleDay = true;
      continue;
    }
    if (token == 'week' || token == 'weekly') {
      relativeDays = 7;
      continue;
    }
    if (token == 'last' && i + 1 < tokens.length) {
      final next = tokens[i + 1].replaceAll(RegExp(r'[^\w]'), '');
      if (next == 'week') {
        relativeDays = 7;
        i++;
        continue;
      }
      if (next == 'month') {
        relativeDays = 31;
        i++;
        continue;
      }
      if (next == 'year') {
        relativeDays = 365;
        i++;
        continue;
      }
    }

    if (token == 'video' || token == 'videos') {
      kind = MediaKind.video;
      continue;
    }
    if (token == 'photo' ||
        token == 'photos' ||
        token == 'images' ||
        token == 'image') {
      kind = MediaKind.image;
      continue;
    }
    if (token == 'screenshot' || token == 'screenshots') {
      screenshotsOnly = true;
      continue;
    }
    if (token == 'favorite' ||
        token == 'favorites' ||
        token == 'favourites' ||
        token == 'favourite') {
      favoritesOnly = true;
      continue;
    }
    if (token == 'large' || token == 'huge' || token == 'big') {
      largeOnly = true;
      continue;
    }

    if (_monthNames.containsKey(token)) {
      month = _monthNames[token];
      continue;
    }

    final asInt = int.tryParse(token);
    if (asInt != null) {
      if (token.length == 4 && asInt >= 1990 && asInt <= 2100) {
        year = asInt;
        continue;
      }
      if (asInt >= 1 && asInt <= 31 && day == null) {
        day = asInt;
        continue;
      }
    }

    leftover.add(token);
  }

  return SearchIntent(
    raw: raw,
    year: year,
    month: month,
    day: day,
    relativeDays: relativeDays,
    relativeSingleDay: relativeSingleDay,
    kind: kind,
    screenshotsOnly: screenshotsOnly,
    favoritesOnly: favoritesOnly,
    largeOnly: largeOnly,
    albumQuery: leftover.isEmpty ? null : leftover.join(' '),
    unrecognized: leftover,
  );
}

List<MediaAsset> applySearch(
  List<MediaAsset> assets,
  SearchIntent intent, {
  DateTime? now,
  List<MediaAlbum> albums = const [],
  List<String> Function(String albumId)? albumAssetIds,
}) {
  if (intent.isEmpty) return assets;
  final clock = now ?? DateTime.now();
  var result = assets;

  if (intent.kind != null) {
    result = result.where((a) => a.kind == intent.kind).toList();
  }
  if (intent.screenshotsOnly) {
    result = result.where((a) => a.isScreenshot).toList();
  }
  if (intent.favoritesOnly) {
    result = result.where((a) => a.isFavorite).toList();
  }
  if (intent.largeOnly) {
    result = result.where((a) => a.isLargeImage || a.isLargeVideo).toList();
  }
  if (intent.year != null) {
    result = result.where((a) => a.createdAt.year == intent.year).toList();
  }
  if (intent.month != null) {
    result = result.where((a) => a.createdAt.month == intent.month).toList();
  }
  if (intent.day != null) {
    result = result.where((a) => a.createdAt.day == intent.day).toList();
  }
  if (intent.relativeDays != null) {
    final today = DateTime(clock.year, clock.month, clock.day);
    final start = today.subtract(Duration(days: intent.relativeDays!));
    final end = intent.relativeSingleDay
        ? start.add(const Duration(days: 1))
        : today.add(const Duration(days: 1));
    result = result
        .where((a) => !a.createdAt.isBefore(start) && a.createdAt.isBefore(end))
        .toList();
  }

  if (intent.albumQuery != null && intent.albumQuery!.isNotEmpty) {
    final q = intent.albumQuery!.toLowerCase();
    final matchedAlbums = albums
        .where((album) => album.name.toLowerCase().contains(q))
        .toList();
    if (matchedAlbums.isEmpty) {
      // Title substring is real metadata, not semantic vision.
      result = result
          .where((a) => (a.title ?? '').toLowerCase().contains(q))
          .toList();
    } else if (albumAssetIds != null) {
      final ids = <String>{};
      for (final album in matchedAlbums) {
        ids.addAll(albumAssetIds(album.id));
      }
      result = result.where((a) => ids.contains(a.id)).toList();
    }
  }

  return result;
}
