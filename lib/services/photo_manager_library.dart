import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../core/errors/luma_exception.dart';
import '../core/theme/luma_tokens.dart';
import '../models/app_models.dart';
import '../models/media_album.dart';
import '../models/media_asset.dart';
import 'media_library.dart';

class PhotoManagerLibrary implements MediaLibrary {
  final Map<String, AssetEntity> _entities = {};
  final Map<String, AssetPathEntity> _paths = {};
  final List<VoidCallback> _listeners = [];
  var _notifying = false;

  static const _option = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.common,
      mediaLocation: true,
    ),
    iosAccessLevel: IosAccessLevel.readWrite,
  );

  LumaPermission _mapPermission(PermissionState state) {
    switch (state) {
      case PermissionState.notDetermined:
        return LumaPermission.notDetermined;
      case PermissionState.denied:
        return LumaPermission.denied;
      case PermissionState.restricted:
        return LumaPermission.restricted;
      case PermissionState.limited:
        return LumaPermission.limited;
      case PermissionState.authorized:
        return LumaPermission.authorized;
    }
  }

  MediaAsset _toAsset(AssetEntity entity) {
    _entities[entity.id] = entity;
    final kind = switch (entity.type) {
      AssetType.video => MediaKind.video,
      AssetType.image => MediaKind.image,
      _ => MediaKind.other,
    };
    return MediaAsset(
      id: entity.id,
      kind: kind,
      createdAt: entity.createDateTime,
      modifiedAt: entity.modifiedDateTime,
      width: entity.width,
      height: entity.height,
      duration: Duration(seconds: entity.duration),
      isFavorite: entity.isFavorite,
      title: entity.title,
      mimeType: entity.mimeType,
      relativePath: entity.relativePath,
      latitude: entity.latLng?.latitude,
      longitude: entity.latLng?.longitude,
      subtype: entity.subtype,
    );
  }

  @override
  Future<LumaPermission> currentPermission() async {
    final state = await PhotoManager.getPermissionState(requestOption: _option);
    return _mapPermission(state);
  }

  @override
  Future<LumaPermission> requestPermission() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: _option,
    );
    return _mapPermission(state);
  }

  @override
  Future<void> openSystemSettings() => PhotoManager.openSetting();

  @override
  Future<void> presentLimitedPicker() {
    return PhotoManager.presentLimited(type: RequestType.common);
  }

  @override
  Future<List<MediaAlbum>> listAlbums() async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
      onlyAll: false,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    _paths
      ..clear()
      ..addEntries(paths.map((p) => MapEntry(p.id, p)));
    final albums = <MediaAlbum>[];
    for (final path in paths) {
      final count = await path.assetCountAsync;
      String? coverId;
      if (count > 0) {
        final cover = await path.getAssetListRange(start: 0, end: 1);
        if (cover.isNotEmpty) {
          _entities[cover.first.id] = cover.first;
          coverId = cover.first.id;
        }
      }
      albums.add(
        MediaAlbum(
          id: path.id,
          name: path.name,
          count: count,
          coverId: coverId,
          isAll: path.isAll,
          isFromDevice: true,
        ),
      );
    }
    return albums;
  }

  @override
  Future<List<String>> assetIdsForAlbum(String albumId) async {
    var path = _paths[albumId];
    if (path == null) {
      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      for (final candidate in paths) {
        _paths[candidate.id] = candidate;
        if (candidate.id == albumId) path = candidate;
      }
    }
    if (path == null) return const [];
    final count = await path.assetCountAsync;
    final ids = <String>[];
    const chunk = 200;
    for (var i = 0; i < count; i += chunk) {
      final end = (i + chunk).clamp(0, count);
      final page = await path.getAssetListRange(start: i, end: end);
      for (final entity in page) {
        _entities[entity.id] = entity;
        ids.add(entity.id);
      }
    }
    return ids;
  }

  @override
  Stream<List<MediaAsset>> pagedAllAssets({int pageSize = 150}) async* {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    if (paths.isEmpty) {
      yield const [];
      return;
    }
    final all = paths.first;
    _paths[all.id] = all;
    final count = await all.assetCountAsync;
    if (count == 0) {
      yield const [];
      return;
    }
    for (var i = 0; i < count; i += pageSize) {
      final end = (i + pageSize).clamp(0, count);
      final page = await all.getAssetListRange(start: i, end: end);
      yield [for (final entity in page) _toAsset(entity)];
    }
  }

  @override
  Future<int?> fileSizeBytes(String id) async {
    final entity = _entities[id] ?? await AssetEntity.fromId(id);
    if (entity == null) return null;
    _entities[id] = entity;
    try {
      return await entity.fileSize;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Uint8List?> thumbnailBytes(String id, {int size = 64}) async {
    final entity = _entities[id] ?? await AssetEntity.fromId(id);
    if (entity == null) return null;
    try {
      return await entity.thumbnailDataWithSize(ThumbnailSize.square(size));
    } catch (_) {
      return null;
    }
  }

  @override
  ImageProvider? thumbnailProvider(String id, {required int size}) {
    final entity = _entities[id];
    if (entity == null) return null;
    return AssetEntityImageProvider(
      entity,
      isOriginal: false,
      thumbnailSize: ThumbnailSize.square(size),
    );
  }

  @override
  ImageProvider? previewProvider(String id) {
    final entity = _entities[id];
    if (entity == null) return null;
    return AssetEntityImageProvider(
      entity,
      isOriginal: false,
      thumbnailSize: const ThumbnailSize(
        LumaTokens.previewViewer,
        LumaTokens.previewViewer,
      ),
    );
  }

  @override
  Future<String?> filePath(String id) async {
    final entity = _entities[id] ?? await AssetEntity.fromId(id);
    if (entity == null) return null;
    try {
      final file = await entity.file;
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> favorite(String id, bool value) async {
    final entity = _entities[id] ?? await AssetEntity.fromId(id);
    if (entity == null) {
      throw const LumaException('This photo is no longer in the library.');
    }
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        _entities[id] = await PhotoManager.editor.darwin.favoriteAsset(
          entity: entity,
          favorite: value,
        );
      } else if (Platform.isAndroid) {
        _entities[id] = await PhotoManager.editor.android.favoriteAsset(
          entity: entity,
          favorite: value,
        );
      } else {
        throw const LumaException(
          'Favorites are not available on this platform.',
        );
      }
    } on LumaException {
      rethrow;
    } catch (error) {
      throw LumaException('Could not update favorite.', cause: error);
    }
  }

  @override
  Future<List<String>> deleteIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    try {
      final deleted = await PhotoManager.editor.deleteWithIds(ids);
      for (final id in deleted) {
        _entities.remove(id);
      }
      return deleted;
    } catch (error) {
      throw LumaException('Could not delete the selected items.', cause: error);
    }
  }

  @override
  Future<MediaAlbum?> createDeviceAlbum(String name) async {
    if (!(Platform.isIOS || Platform.isMacOS)) return null;
    final path = await PhotoManager.editor.darwin.createAlbum(name);
    if (path == null) return null;
    _paths[path.id] = path;
    return MediaAlbum(
      id: path.id,
      name: path.name,
      count: 0,
      isFromDevice: true,
    );
  }

  @override
  Future<void> addToDeviceAlbum(String albumId, List<String> assetIds) async {
    final path = _paths[albumId];
    if (path == null) {
      throw const LumaException('That album is no longer available.');
    }
    for (final id in assetIds) {
      final entity = _entities[id] ?? await AssetEntity.fromId(id);
      if (entity == null) continue;
      await PhotoManager.editor.copyAssetToPath(
        asset: entity,
        pathEntity: path,
      );
    }
  }

  @override
  void addChangeListener(VoidCallback listener) {
    if (_listeners.isEmpty && !_notifying) {
      PhotoManager.addChangeCallback(_onOsChange);
      PhotoManager.startChangeNotify();
      _notifying = true;
    }
    _listeners.add(listener);
  }

  @override
  void removeChangeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty && _notifying) {
      PhotoManager.stopChangeNotify();
      PhotoManager.removeChangeCallback(_onOsChange);
      _notifying = false;
    }
  }

  void _onOsChange(MethodCall call) {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  @override
  Future<void> clearCaches() => PhotoManager.clearFileCache();
}
