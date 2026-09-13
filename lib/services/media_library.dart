import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../models/app_models.dart';
import '../models/media_album.dart';
import '../models/media_asset.dart';

abstract class MediaLibrary {
  LibraryAccessMode get accessMode;

  Future<LumaPermission> currentPermission();
  Future<LumaPermission> requestPermission();
  Future<void> openSystemSettings();
  Future<void> presentLimitedPicker();

  Future<List<MediaAlbum>> listAlbums();
  Future<List<String>> assetIdsForAlbum(String albumId);

  /// Newest first.
  Stream<List<MediaAsset>> pagedAllAssets({int pageSize = 150});

  Future<int?> fileSizeBytes(String id);
  Future<Uint8List?> thumbnailBytes(String id, {int size = 64});
  ImageProvider? thumbnailProvider(String id, {required int size});
  ImageProvider? previewProvider(String id);
  Future<String?> filePath(String id);

  /// Blob/http URL for in-app playback. Null when [filePath] should be used.
  String? playbackUrl(String id);

  /// Original file bytes when a filesystem path is unavailable (web session).
  Future<Uint8List?> originalBytes(String id);

  Future<void> favorite(String id, bool value);
  Future<List<String>> deleteIds(List<String> ids);

  Future<MediaAlbum?> createDeviceAlbum(String name);
  Future<void> addToDeviceAlbum(String albumId, List<String> assetIds);

  void addChangeListener(VoidCallback listener);
  void removeChangeListener(VoidCallback listener);

  Future<void> clearCaches();
}
