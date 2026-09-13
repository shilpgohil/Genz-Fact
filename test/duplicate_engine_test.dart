import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/duplicate_group.dart';
import 'package:luma/services/duplicate_engine.dart';

import 'helpers/media_fixtures.dart';

void main() {
  test('exact duplicates require size and matching dimensions', () {
    final assets = [
      sampleAsset(id: 'a', fileSizeBytes: 1000, width: 10, height: 10),
      sampleAsset(id: 'b', fileSizeBytes: 1000, width: 10, height: 10),
      sampleAsset(id: 'c', fileSizeBytes: 1000, width: 11, height: 10),
      sampleAsset(id: 'd', fileSizeBytes: null, width: 10, height: 10),
    ];
    final groups = findExactDuplicates(assets);
    expect(groups, hasLength(1));
    expect(groups.first.items.map((e) => e.id), containsAll(['a', 'b']));
    expect(groups.first.kind, DuplicateKind.exact);
  });

  test('recommended keep is the newest when sizes match', () {
    final assets = [
      sampleAsset(
        id: 'old',
        fileSizeBytes: 400,
        width: 12,
        height: 12,
        createdAt: DateTime(2020),
      ),
      sampleAsset(
        id: 'new',
        fileSizeBytes: 400,
        width: 12,
        height: 12,
        createdAt: DateTime(2021),
      ),
    ];
    final group = findExactDuplicates(assets).single;
    expect(group.recommendedKeep.id, 'new');
    expect(group.reclaimableBytes, 400);
  });

  test('near duplicates use hamming distance', () {
    final assets = [
      sampleAsset(id: 'a', perceptualHash: 0),
      sampleAsset(id: 'b', perceptualHash: 1),
      sampleAsset(id: 'c', perceptualHash: 0xFFFFFFFFFFFFFFF),
    ];
    final groups = findNearDuplicates(assets, maxDistance: 2);
    expect(groups, hasLength(1));
    expect(groups.single.items.map((e) => e.id), containsAll(['a', 'b']));
  });

  test('dHash is stable for a luminance grid', () {
    final leftDark = List<int>.generate(72, (i) {
      final x = i % 9;
      return x < 4 ? 0 : 255;
    });
    final rightDark = List<int>.generate(72, (i) {
      final x = i % 9;
      return x < 4 ? 255 : 0;
    });
    expect(dHashFromLuma(leftDark), dHashFromLuma(leftDark));
    expect(dHashFromLuma(leftDark), isNot(dHashFromLuma(rightDark)));
  });

  test('hamming distance of identical hashes is zero', () {
    expect(hammingDistance(42, 42), 0);
    expect(hammingDistance(0, 1), 1);
  });
}
