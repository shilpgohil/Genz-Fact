import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../models/app_models.dart';
import '../models/media_album.dart';
import '../models/media_asset.dart';
import 'media_library.dart';

class SessionFile {
  const SessionFile({
    required this.name,
    required this.bytes,
    required this.lastModified,
    this.mimeType,
    this.relativePath,
    this.width,
    this.height,
    this.duration = Duration.zero,
    this.objectUrl,
    this.sizeBytes,
  });

  final String name;
  final Uint8List bytes;
  final DateTime lastModified;
  final String? mimeType;
  final String? relativePath;
  final int? width;
  final int? height;
  final Duration duration;
  final String? objectUrl;
  final int? sizeBytes;
}

class _SessionItem {
  _SessionItem({
    required this.asset,
    required this.bytes,
    this.objectUrl,
    this.folder,
  });

  MediaAsset asset;
  final Uint8List bytes;
  final String? objectUrl;
  final String? folder;
}

/// In-memory library for the web (and tests). Files never leave the process.
class SessionMediaLibrary implements MediaLibrary {
  SessionMediaLibrary({this.pickFiles});

  final Future<List<SessionFile>> Function()? pickFiles;

  final Map<String, _SessionItem> _items = {};
  final List<VoidCallback> _listeners = [];
  var _seq = 0;
  LumaPermission _permission = LumaPermission.notDetermined;

  @override
  LibraryAccessMode get accessMode => LibraryAccessMode.session;

  Future<LumaPermission> ingest(List<SessionFile> files) async {
    if (files.isEmpty) return _permission;
    for (final file in files) {
      _seq += 1;
      final id = 'session-$_seq';
      final mime = (file.mimeType ?? '').toLowerCase();
      final name = file.name.toLowerCase();
      final kind = mime.startsWith('video/') || _isVideoName(name)
          ? MediaKind.video
          : MediaKind.image;
      final folder = _folderOf(file.relativePath);
      _items[id] = _SessionItem(
        bytes: file.bytes,
        objectUrl: file.objectUrl,
        folder: folder,
        asset: MediaAsset(
          id: id,
          kind: kind,
          createdAt: file.lastModified,
          modifiedAt: file.lastModified,
          width: file.width ?? 0,
          height: file.height ?? 0,
          duration: file.duration,
          fileSizeBytes: file.sizeBytes ?? file.bytes.length,
          title: file.name,
          mimeType: file.mimeType,
          relativePath: file.relativePath,
        ),
      );
    }
    _permission = LumaPermission.authorized;
    return _permission;
  }

  List<MediaAsset> _sortedAssets() {
    final assets = [for (final item in _items.values) item.asset];
    assets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assets;
  }

  static bool _isVideoName(String name) {
    return name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.m4v') ||
        name.endsWith('.webm');
  }

  static String? _folderOf(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    final normalized = relativePath.replaceAll('\\', '/');
    final parts = normalized.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return null;
    return parts.first;
  }

  @override
  Future<LumaPermission> currentPermission() async => _permission;

  @override
  Future<LumaPermission> requestPermission() async {
    if (_permission.hasAccess && _items.isNotEmpty) return _permission;
    final picker = pickFiles;
    if (picker == null) return _permission;
    final files = await picker();
    if (files.isEmpty) return _permission;
    return ingest(files);
  }

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> presentLimitedPicker() async {
    final picker = pickFiles;
    if (picker == null) return;
    final files = await picker();
    if (files.isNotEmpty) await ingest(files);
  }

  @override
  Future<List<MediaAlbum>> listAlbums() async {
    final assets = _sortedAssets();
    final albums = <MediaAlbum>[
      MediaAlbum(
        id: 'session-all',
        name: 'Recents',
        count: assets.length,
        coverId: assets.isEmpty ? null : assets.first.id,
        isAll: true,
        isFromDevice: false,
      ),
    ];
    final folders = <String, List<String>>{};
    for (final item in _items.values) {
      final folder = item.folder;
      if (folder == null) continue;
      folders.putIfAbsent(folder, () => []).add(item.asset.id);
    }
    final names = folders.keys.toList()..sort();
    for (final name in names) {
      final ids = folders[name]!;
      albums.add(
        MediaAlbum(
          id: 'session-folder-$name',
          name: name,
          count: ids.length,
          coverId: ids.isEmpty ? null : ids.first,
          isFromDevice: false,
        ),
      );
    }
    return albums;
  }

  @override
  Future<List<String>> assetIdsForAlbum(String albumId) async {
    if (albumId == 'session-all') {
      return _sortedAssets().map((a) => a.id).toList();
    }
    const prefix = 'session-folder-';
    if (!albumId.startsWith(prefix)) return const [];
    final folder = albumId.substring(prefix.length);
    return [
      for (final asset in _sortedAssets())
        if (_items[asset.id]?.folder == folder) asset.id,
    ];
  }

  @override
  Stream<List<MediaAsset>> pagedAllAssets({int pageSize = 150}) async* {
    final assets = _sortedAssets();
    if (assets.isEmpty) {
      yield const [];
      return;
    }
    for (var i = 0; i < assets.length; i += pageSize) {
      final end = (i + pageSize).clamp(0, assets.length);
      yield assets.sublist(i, end);
    }
  }

  @override
  Future<int?> fileSizeBytes(String id) async =>
      _items[id]?.asset.fileSizeBytes;

  @override
  Future<Uint8List?> thumbnailBytes(String id, {int size = 64}) async =>
      _items[id]?.bytes;

  @override
  ImageProvider? thumbnailProvider(String id, {required int size}) {
    final item = _items[id];
    if (item == null) return null;
    if (item.bytes.isNotEmpty) return MemoryImage(item.bytes);
    if (item.objectUrl != null && item.asset.isImage) {
      return NetworkImage(item.objectUrl!);
    }
    return null;
  }

  @override
  ImageProvider? previewProvider(String id) =>
      thumbnailProvider(id, size: 1600);

  @override
  Future<String?> filePath(String id) async => null;

  @override
  String? playbackUrl(String id) => _items[id]?.objectUrl;

  @override
  Future<Uint8List?> originalBytes(String id) async => _items[id]?.bytes;

  @override
  Future<void> favorite(String id, bool value) async {
    final item = _items[id];
    if (item == null) return;
    item.asset = item.asset.copyWith(isFavorite: value);
  }

  @override
  Future<List<String>> deleteIds(List<String> ids) async {
    final deleted = <String>[];
    for (final id in ids) {
      if (_items.remove(id) != null) deleted.add(id);
    }
    return deleted;
  }

  @override
  Future<MediaAlbum?> createDeviceAlbum(String name) async => null;

  @override
  Future<void> addToDeviceAlbum(String albumId, List<String> assetIds) async {}

  @override
  void addChangeListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeChangeListener(VoidCallback listener) =>
      _listeners.remove(listener);

  @override
  Future<void> clearCaches() async {}
}
