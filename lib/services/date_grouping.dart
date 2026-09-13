import '../models/date_section.dart';
import '../models/media_asset.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Groups assets by local calendar day, newest day first. Assets inside a day
/// stay newest-first.
List<DateSection> groupByDay(List<MediaAsset> assets) {
  if (assets.isEmpty) return const [];
  final map = <DateTime, List<MediaAsset>>{};
  for (final asset in assets) {
    final key = dateOnly(asset.createdAt);
    (map[key] ??= []).add(asset);
  }
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final key in keys)
      DateSection(date: key, assets: List<MediaAsset>.unmodifiable(map[key]!)),
  ];
}

List<GalleryRow> buildGalleryRows(List<DateSection> sections, int columns) {
  final cols = columns < 1 ? 1 : columns;
  final rows = <GalleryRow>[];
  for (final section in sections) {
    rows.add(GalleryRow.header(section.date));
    for (var i = 0; i < section.assets.length; i += cols) {
      final end = (i + cols).clamp(0, section.assets.length);
      rows.add(GalleryRow.photos(section.assets.sublist(i, end)));
    }
  }
  return rows;
}

List<DateTime> monthAnchors(List<MediaAsset> assets) {
  final seen = <String>{};
  final out = <DateTime>[];
  for (final asset in assets) {
    final key = '${asset.createdAt.year}-${asset.createdAt.month}';
    if (seen.add(key)) {
      out.add(DateTime(asset.createdAt.year, asset.createdAt.month));
    }
  }
  return out;
}
