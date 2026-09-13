import 'media_asset.dart';

enum DuplicateKind { exact, near }

class DuplicateGroup {
  const DuplicateGroup({
    required this.id,
    required this.kind,
    required this.items,
  });

  final String id;
  final DuplicateKind kind;
  final List<MediaAsset> items;

  /// Largest file, then newest — keep this one by default.
  MediaAsset get recommendedKeep {
    final copy = [...items]
      ..sort((a, b) {
        final size = (b.fileSizeBytes ?? 0).compareTo(a.fileSizeBytes ?? 0);
        if (size != 0) return size;
        return b.createdAt.compareTo(a.createdAt);
      });
    return copy.first;
  }

  int get reclaimableBytes {
    final keep = recommendedKeep.id;
    var sum = 0;
    for (final item in items) {
      if (item.id == keep) continue;
      sum += item.fileSizeBytes ?? 0;
    }
    return sum;
  }
}
