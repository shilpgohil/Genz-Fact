import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/media_album.dart';
import 'package:luma/models/media_asset.dart';
import 'package:luma/services/search_engine.dart';

import 'helpers/media_fixtures.dart';

void main() {
  final now = DateTime(2025, 9, 13, 15);
  final assets = [
    sampleAsset(id: 'aug', createdAt: DateTime(2025, 8, 18)),
    sampleAsset(id: 'yesterday', createdAt: DateTime(2025, 9, 12, 10)),
    sampleAsset(
      id: 'vid',
      createdAt: DateTime(2025, 9, 13, 9),
      kind: MediaKind.video,
    ),
    sampleAsset(
      id: 'shot',
      createdAt: DateTime(2024, 1, 1),
      title: 'Screenshot_1',
    ),
    sampleAsset(id: 'fav', createdAt: DateTime(2025, 1, 2), isFavorite: true),
    sampleAsset(
      id: 'large',
      createdAt: DateTime(2025, 2, 2),
      fileSizeBytes: 12 * 1024 * 1024,
    ),
  ];

  test('parses month, year, and media type', () {
    final intent = parseSearchQuery('August 2025 photos');
    expect(intent.month, 8);
    expect(intent.year, 2025);
    expect(intent.kind, MediaKind.image);
  });

  test('filters yesterday relative to provided now', () {
    final intent = parseSearchQuery('Yesterday');
    final result = applySearch(assets, intent, now: now);
    expect(result.map((a) => a.id), ['yesterday']);
  });

  test('filters videos and screenshots', () {
    expect(applySearch(assets, parseSearchQuery('videos')).map((a) => a.id), [
      'vid',
    ]);
    expect(
      applySearch(assets, parseSearchQuery('screenshots')).map((a) => a.id),
      ['shot'],
    );
  });

  test('filters favorites and large photos', () {
    expect(applySearch(assets, parseSearchQuery('favorites')).single.id, 'fav');
    expect(
      applySearch(assets, parseSearchQuery('large photos')).single.id,
      'large',
    );
  });

  test('matches album names when membership is provided', () {
    final albums = [const MediaAlbum(id: 'a1', name: 'Goa Trip', count: 1)];
    final result = applySearch(
      assets,
      parseSearchQuery('Goa'),
      albums: albums,
      albumAssetIds: (id) => id == 'a1' ? ['aug'] : const [],
    );
    expect(result.single.id, 'aug');
  });
}
