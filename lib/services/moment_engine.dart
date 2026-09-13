import 'package:intl/intl.dart';

import '../core/theme/luma_tokens.dart';
import '../core/utilities/formatters.dart';
import '../models/media_asset.dart';
import '../models/media_moment.dart';

/// Clusters photos that were captured close together.
///
/// Titles use weekday, time of day, date span, or a shared non-generic album
/// name when callers pass [albumNameForAsset]. Never invents cities or events.
List<MediaMoment> clusterMoments(
  List<MediaAsset> assets, {
  Duration gap = LumaTokens.momentGap,
  int minItems = LumaTokens.momentMinItems,
  String? Function(MediaAsset asset)? albumNameForAsset,
}) {
  if (assets.isEmpty) return const [];
  final sorted = [...assets]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final clusters = <List<MediaAsset>>[];
  var current = <MediaAsset>[sorted.first];
  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1];
    final next = sorted[i];
    if (next.createdAt.difference(prev.createdAt) <= gap) {
      current.add(next);
    } else {
      clusters.add(current);
      current = [next];
    }
  }
  clusters.add(current);

  final moments = <MediaMoment>[];
  for (var i = 0; i < clusters.length; i++) {
    final cluster = clusters[i];
    if (cluster.length < minItems) continue;
    final start = cluster.first.createdAt;
    final end = cluster.last.createdAt;
    final album = _sharedAlbum(cluster, albumNameForAsset);
    moments.add(
      MediaMoment(
        id: 'moment-$i-${start.millisecondsSinceEpoch}',
        title: _title(cluster, album),
        subtitle: _subtitle(cluster, start, end),
        assets: List<MediaAsset>.unmodifiable(cluster.reversed),
        start: start,
        end: end,
      ),
    );
  }
  return moments.reversed.toList(growable: false);
}

String? _sharedAlbum(
  List<MediaAsset> cluster,
  String? Function(MediaAsset asset)? albumNameForAsset,
) {
  if (albumNameForAsset == null) return null;
  String? name;
  for (final asset in cluster) {
    final next = albumNameForAsset(asset);
    if (next == null || _isGenericAlbum(next)) return null;
    if (name == null) {
      name = next;
    } else if (name != next) {
      return null;
    }
  }
  return name;
}

bool _isGenericAlbum(String name) {
  final n = name.trim().toLowerCase();
  return n.isEmpty ||
      n == 'recents' ||
      n == 'recent' ||
      n == 'all' ||
      n == 'camera' ||
      n == 'camera roll' ||
      n == 'screenshots' ||
      n == 'videos' ||
      n == 'favorites';
}

String _title(List<MediaAsset> cluster, String? album) {
  final start = cluster.first.createdAt;
  final end = cluster.last.createdAt;
  if (album != null) {
    return '$album · ${DateFormat('MMM d').format(start)}';
  }
  if (!_sameDay(start, end)) {
    if (_weekendSpan(start, end)) {
      return 'Weekend · ${DateFormat('MMM d').format(start)}';
    }
    return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d').format(end)}';
  }
  final weekday = DateFormat('EEEE').format(start);
  return '$weekday ${dayPartLabel(dayPartOf(start))}';
}

String _subtitle(List<MediaAsset> cluster, DateTime start, DateTime end) {
  final count = '${cluster.length} items';
  if (_sameDay(start, end)) {
    return '${DateFormat('MMM d, y').format(start)} · $count';
  }
  return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d, y').format(end)} · $count';
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _weekendSpan(DateTime start, DateTime end) {
  if (end.difference(start) > const Duration(days: 2)) return false;
  bool isWe(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
  return isWe(start) && isWe(end);
}
