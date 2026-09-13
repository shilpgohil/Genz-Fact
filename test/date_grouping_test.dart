import 'package:flutter_test/flutter_test.dart';
import 'package:luma/services/date_grouping.dart';

import 'helpers/media_fixtures.dart';

void main() {
  test('groups by local day, newest first', () {
    final assets = [
      sampleAsset(id: 'a', createdAt: DateTime(2025, 8, 18, 9)),
      sampleAsset(id: 'b', createdAt: DateTime(2025, 8, 19, 11)),
      sampleAsset(id: 'c', createdAt: DateTime(2025, 8, 18, 21)),
    ];
    final sections = groupByDay(assets);
    expect(sections, hasLength(2));
    expect(sections.first.date, DateTime(2025, 8, 19));
    expect(sections.first.assets.map((a) => a.id), ['b']);
    expect(sections.last.assets.map((a) => a.id), ['a', 'c']);
  });

  test('builds photo rows for a column count', () {
    final assets = [
      for (var i = 0; i < 5; i++)
        sampleAsset(id: '$i', createdAt: DateTime(2025, 1, 1, i)),
    ];
    final rows = buildGalleryRows(groupByDay(assets), 3);
    expect(rows.first.kind.name, 'header');
    expect(rows.where((r) => r.kind.name == 'photos'), hasLength(2));
    expect(rows[1].assets, hasLength(3));
    expect(rows[2].assets, hasLength(2));
  });

  test('month anchors are unique', () {
    final assets = [
      sampleAsset(id: '1', createdAt: DateTime(2025, 8, 1)),
      sampleAsset(id: '2', createdAt: DateTime(2025, 8, 20)),
      sampleAsset(id: '3', createdAt: DateTime(2024, 1, 2)),
    ];
    final months = monthAnchors(assets);
    expect(months, hasLength(2));
  });
}
