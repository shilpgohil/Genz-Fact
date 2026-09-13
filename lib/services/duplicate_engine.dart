import '../core/theme/luma_tokens.dart';
import '../models/duplicate_group.dart';
import '../models/media_asset.dart';

int hammingDistance(int a, int b) {
  var x = a ^ b;
  var count = 0;
  while (x != 0) {
    count += x & 1;
    x >>= 1;
  }
  return count;
}

/// dHash from a 9×8 luminance grid (row-major, 72 values, 0–255).
int dHashFromLuma(List<int> pixels) {
  if (pixels.length < 72) {
    throw ArgumentError('dHash expects 9x8 luminance samples');
  }
  var hash = 0;
  for (var y = 0; y < 8; y++) {
    for (var x = 0; x < 8; x++) {
      hash <<= 1;
      final left = pixels[y * 9 + x];
      final right = pixels[y * 9 + x + 1];
      if (left > right) hash |= 1;
    }
  }
  return hash;
}

int dHashFromRgba(List<int> rgba, int width, int height) {
  const tw = 9;
  const th = 8;
  final samples = List<int>.filled(tw * th, 0);
  for (var y = 0; y < th; y++) {
    for (var x = 0; x < tw; x++) {
      final sx = ((x + 0.5) * width / tw).floor().clamp(0, width - 1);
      final sy = ((y + 0.5) * height / th).floor().clamp(0, height - 1);
      final i = (sy * width + sx) * 4;
      final r = rgba[i];
      final g = rgba[i + 1];
      final b = rgba[i + 2];
      samples[y * tw + x] = ((r * 299 + g * 587 + b * 114) / 1000).round();
    }
  }
  return dHashFromLuma(samples);
}

String exactDuplicateKey(MediaAsset asset) {
  final size = asset.fileSizeBytes;
  if (size == null || size <= 0) return '';
  return '$size:${asset.width}x${asset.height}:${asset.kind.name}:${asset.duration.inMilliseconds}';
}

/// Exact duplicates require a known file size plus matching dimensions.
List<DuplicateGroup> findExactDuplicates(List<MediaAsset> assets) {
  final buckets = <String, List<MediaAsset>>{};
  for (final asset in assets) {
    final key = exactDuplicateKey(asset);
    if (key.isEmpty) continue;
    (buckets[key] ??= []).add(asset);
  }
  final groups = <DuplicateGroup>[];
  var i = 0;
  for (final entry in buckets.entries) {
    if (entry.value.length < 2) continue;
    groups.add(
      DuplicateGroup(
        id: 'exact-$i-${entry.key}',
        kind: DuplicateKind.exact,
        items: List<MediaAsset>.unmodifiable(entry.value),
      ),
    );
    i++;
  }
  return groups;
}

/// Near duplicates using 64-bit dHash. Assets without a hash are ignored.
List<DuplicateGroup> findNearDuplicates(
  List<MediaAsset> assets, {
  int maxDistance = LumaTokens.nearDuplicateHamming,
}) {
  final hashed = assets.where((a) => a.perceptualHash != null).toList();
  final used = <String>{};
  final groups = <DuplicateGroup>[];
  var gi = 0;
  for (var i = 0; i < hashed.length; i++) {
    final a = hashed[i];
    if (used.contains(a.id)) continue;
    final bucket = <MediaAsset>[a];
    for (var j = i + 1; j < hashed.length; j++) {
      final b = hashed[j];
      if (used.contains(b.id)) continue;
      if (hammingDistance(a.perceptualHash!, b.perceptualHash!) <=
          maxDistance) {
        bucket.add(b);
      }
    }
    if (bucket.length < 2) continue;
    for (final item in bucket) {
      used.add(item.id);
    }
    groups.add(
      DuplicateGroup(
        id: 'near-$gi-${a.id}',
        kind: DuplicateKind.near,
        items: List<MediaAsset>.unmodifiable(bucket),
      ),
    );
    gi++;
  }
  return groups;
}

List<DuplicateGroup> mergeDuplicateGroups(
  List<DuplicateGroup> exact,
  List<DuplicateGroup> near,
) {
  final out = [...exact];
  for (final group in near) {
    final ids = group.items.map((e) => e.id).toSet();
    final covered = exact.any(
      (e) => e.items.map((x) => x.id).toSet().containsAll(ids),
    );
    if (!covered) out.add(group);
  }
  return out;
}
