import 'package:flutter_test/flutter_test.dart';
import 'package:luma/core/utilities/formatters.dart';
import 'package:luma/services/category_engine.dart';

import 'helpers/media_fixtures.dart';

void main() {
  test('formatBytes handles null without inventing a total', () {
    expect(formatBytes(null), 'Unknown size');
    expect(formatBytes(1024), '1 KB');
  });

  test('buildHealth known bytes only sums sized assets', () {
    final assets = [
      sampleAsset(id: 'a', fileSizeBytes: 100),
      sampleAsset(id: 'b', fileSizeBytes: null),
    ];
    final health = buildHealth(assets);
    expect(health.knownBytes, 100);
    expect(health.sizesComplete, isFalse);
    expect(health.totalCount, 2);
  });
}
