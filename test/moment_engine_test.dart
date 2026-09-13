import 'package:flutter_test/flutter_test.dart';
import 'package:luma/services/moment_engine.dart';

import 'helpers/media_fixtures.dart';

void main() {
  test('clusters photos within the gap and skips tiny groups', () {
    final assets = [
      sampleAsset(id: '1', createdAt: DateTime(2025, 8, 18, 18)),
      sampleAsset(id: '2', createdAt: DateTime(2025, 8, 18, 18, 20)),
      sampleAsset(id: '3', createdAt: DateTime(2025, 8, 18, 18, 40)),
      sampleAsset(id: 'lonely', createdAt: DateTime(2025, 8, 21, 12)),
    ];
    final moments = clusterMoments(assets);
    expect(moments, hasLength(1));
    expect(moments.first.assets, hasLength(3));
    expect(moments.first.title, contains('Evening'));
  });

  test('does not invent event names', () {
    final assets = [
      for (var i = 0; i < 4; i++)
        sampleAsset(id: '$i', createdAt: DateTime(2025, 8, 16, 21, i)),
    ];
    final moments = clusterMoments(assets);
    expect(moments.first.title.toLowerCase(), isNot(contains('birthday')));
    expect(moments.first.title.toLowerCase(), isNot(contains('trip')));
  });

  test('uses a shared non-generic album name when provided', () {
    final assets = [
      for (var i = 0; i < 3; i++)
        sampleAsset(id: '$i', createdAt: DateTime(2025, 6, 1, 10, i)),
    ];
    final moments = clusterMoments(assets, albumNameForAsset: (_) => 'Goa');
    expect(moments.first.title, startsWith('Goa'));
  });
}
