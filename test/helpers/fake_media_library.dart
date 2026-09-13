import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:luma/models/app_models.dart';
import 'package:luma/models/media_album.dart';
import 'package:luma/models/media_asset.dart';
import 'package:luma/services/media_library.dart';

class FakeMediaLibrary implements MediaLibrary {
  FakeMediaLibrary({
    this.permission = LumaPermission.authorized,
    List<MediaAsset> assets = const [],
    List<MediaAlbum> albums = const [],
  }) : assets = List.of(assets),
       albums = List.of(albums);

  LumaPermission permission;
  List<MediaAsset> assets;
  List<MediaAlbum> albums;
  final listeners = <VoidCallback>[];
  final deleted = <String>[];
  final favorites = <String, bool>{};

  @override
  Future<LumaPermission> currentPermission() async => permission;

  @override
  Future<LumaPermission> requestPermission() async => permission;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> presentLimitedPicker() async {}

  @override
  Future<List<MediaAlbum>> listAlbums() async => albums;

  @override
  Future<List<String>> assetIdsForAlbum(String albumId) async {
    final album = albums.where((a) => a.id == albumId);
    if (album.isEmpty || album.first.isAll) {
      return assets.map((a) => a.id).toList();
    }
    return const [];
  }

  @override
  Stream<List<MediaAsset>> pagedAllAssets({int pageSize = 150}) async* {
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
  Future<int?> fileSizeBytes(String id) async {
    return assets.where((a) => a.id == id).firstOrNull?.fileSizeBytes;
  }

  @override
  Future<Uint8List?> thumbnailBytes(String id, {int size = 64}) async => null;

  @override
  ImageProvider? thumbnailProvider(String id, {required int size}) => null;

  @override
  ImageProvider? previewProvider(String id) => null;

  @override
  Future<String?> filePath(String id) async => null;

  @override
  Future<void> favorite(String id, bool value) async {
    favorites[id] = value;
  }

  @override
  Future<List<String>> deleteIds(List<String> ids) async {
    deleted.addAll(ids);
    assets.removeWhere((a) => ids.contains(a.id));
    return ids;
  }

  @override
  Future<MediaAlbum?> createDeviceAlbum(String name) async => null;

  @override
  Future<void> addToDeviceAlbum(String albumId, List<String> assetIds) async {}

  @override
  void addChangeListener(VoidCallback listener) => listeners.add(listener);

  @override
  void removeChangeListener(VoidCallback listener) =>
      listeners.remove(listener);

  @override
  Future<void> clearCaches() async {}
}
