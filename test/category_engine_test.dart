import 'package:flutter_test/flutter_test.dart';
import 'package:luma/core/theme/luma_tokens.dart';
import 'package:luma/models/library_health.dart';
import 'package:luma/models/media_asset.dart';
import 'package:luma/services/category_engine.dart';

import 'helpers/media_fixtures.dart';

void main() {
  final now = DateTime(2025, 9, 13);
  final assets = [
    sampleAsset(id: 'new', createdAt: now.subtract(const Duration(days: 1))),
    sampleAsset(id: 'fav', isFavorite: true, createdAt: DateTime(2024)),
    sampleAsset(
      id: 'vid',
      kind: MediaKind.video,
      createdAt: DateTime(2024),
      duration: const Duration(seconds: 12),
    ),
    sampleAsset(
      id: 'shot',
      title: 'Screenshot 12',
      relativePath: 'Pictures/Screenshots',
      createdAt: DateTime(2024),
    ),
    sampleAsset(
      id: 'huge',
      fileSizeBytes: LumaTokens.largeImageBytes + 10,
      createdAt: DateTime(2024),
    ),
    sampleAsset(id: 'b1', createdAt: DateTime(2025, 1, 1, 12, 0, 0)),
    sampleAsset(id: 'b2', createdAt: DateTime(2025, 1, 1, 12, 0, 1)),
    sampleAsset(id: 'b3', createdAt: DateTime(2025, 1, 1, 12, 0, 1, 200)),
  ];

  test('omits empty categories', () {
    final cats = visibleCategories(assets, now: now);
    expect(
      cats.map((c) => c.kind),
      isNot(contains(MediaCategoryKind.portraits)),
    );
    expect(cats.map((c) => c.kind), contains(MediaCategoryKind.videos));
    expect(cats.map((c) => c.kind), contains(MediaCategoryKind.screenshots));
    expect(cats.map((c) => c.kind), contains(MediaCategoryKind.bursts));
  });

  test('screenshot detection uses title and path', () {
    expect(screenshotAssets(assets).map((a) => a.id), contains('shot'));
  });

  test('health counts are honest about known bytes', () {
    final health = buildHealth(assets, now: now);
    expect(health.videoCount, 1);
    expect(health.favoriteCount, 1);
    expect(health.screenshotCount, 1);
    expect(health.sizedAssetCount, assets.length);
  });
}
