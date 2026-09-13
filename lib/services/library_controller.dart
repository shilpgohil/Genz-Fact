import 'dart:async';

import 'package:flutter/widgets.dart';

// Named constructor args stay public (`library`, `settings`).
// ignore_for_file: prefer_initializing_formals

import '../core/errors/luma_exception.dart';
import '../core/theme/luma_tokens.dart';
import '../models/app_models.dart';
import '../models/date_section.dart';
import '../models/duplicate_group.dart';
import '../models/library_health.dart';
import '../models/media_album.dart';
import '../models/media_asset.dart';
import '../models/media_moment.dart';
import 'category_engine.dart';
import 'date_grouping.dart';
import 'duplicate_engine.dart';
import 'hash_service.dart';
import 'media_library.dart';
import 'moment_engine.dart';
import 'search_engine.dart';
import 'settings_store.dart';

class LibraryController extends ChangeNotifier with WidgetsBindingObserver {
  LibraryController({
    required MediaLibrary library,
    required SettingsStore settings,
  }) : _library = library,
       _settings = settings;

  final MediaLibrary _library;
  final SettingsStore _settings;

  LibraryPhase phase = LibraryPhase.booting;
  LumaPermission permission = LumaPermission.unknown;
  String? errorMessage;
  var indexing = false;
  var sizing = false;
  var scanningSimilar = false;
  var indexedCount = 0;

  List<MediaAsset> _assets = const [];
  Map<String, MediaAsset> _byId = const {};
  List<MediaAlbum> deviceAlbums = const [];
  List<MediaMoment> moments = const [];
  List<MediaCategory> categories = const [];
  List<DuplicateGroup> duplicateGroups = const [];
  LibraryHealth health = const LibraryHealth(
    photoCount: 0,
    videoCount: 0,
    screenshotCount: 0,
    favoriteCount: 0,
    largeCount: 0,
    duplicateCandidateCount: 0,
    knownBytes: 0,
    sizedAssetCount: 0,
    totalCount: 0,
    recentCount: 0,
  );

  Map<String, List<String>> _albumIdToAssets = const {};
  Timer? _changeDebounce;
  var _disposed = false;
  var _backfillGeneration = 0;

  MediaLibrary get library => _library;
  SettingsStore get settingsStore => _settings;
  AppSettings get appSettings => _settings.settings;
  List<MediaAsset> get assets => _assets;
  List<LumaCollection> get collections => _settings.collections;
  bool get isSessionLibrary => _library.accessMode == LibraryAccessMode.session;

  List<MediaAsset> get visibleAssets {
    if (_settings.settings.includeVideos) return _assets;
    return _assets.where((a) => !a.isVideo).toList();
  }

  MediaAsset? byId(String id) => _byId[id];

  List<MediaAsset> assetsByIds(Iterable<String> ids) {
    return [
      for (final id in ids)
        if (_byId[id] != null) _byId[id]!,
    ];
  }

  ImageProvider? thumb(String id, {int size = LumaTokens.thumbnailGrid}) =>
      _library.thumbnailProvider(id, size: size);

  ImageProvider? preview(String id) => _library.previewProvider(id);

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    _settings.addListener(_onSettingsChanged);
    _library.addChangeListener(_onLibraryChanged);
    try {
      permission = await _library.currentPermission();
    } catch (_) {
      permission = LumaPermission.notDetermined;
    }
    if (permission.hasAccess) {
      await loadLibrary();
    } else {
      phase = LibraryPhase.needsPermission;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(recheckPermission());
    }
  }

  Future<void> recheckPermission() async {
    try {
      final next = await _library.currentPermission();
      if (next != permission) {
        permission = next;
        if (next.hasAccess) {
          await loadLibrary();
        } else {
          phase = LibraryPhase.needsPermission;
          notifyListeners();
        }
      }
    } catch (_) {
      // Stay on the last known state.
    }
  }

  Future<void> requestAccess() async {
    errorMessage = null;
    notifyListeners();
    try {
      permission = await _library.requestPermission();
    } catch (error) {
      errorMessage = 'Could not request photo access.';
      phase = LibraryPhase.needsPermission;
      notifyListeners();
      return;
    }
    if (permission.hasAccess) {
      await loadLibrary();
    } else {
      phase = LibraryPhase.needsPermission;
      notifyListeners();
    }
  }

  Future<void> openSettings() => _library.openSystemSettings();

  Future<void> manageLimitedAccess() async {
    await _library.presentLimitedPicker();
    await loadLibrary();
  }

  Future<void> loadLibrary() async {
    if (!permission.hasAccess) {
      phase = LibraryPhase.needsPermission;
      notifyListeners();
      return;
    }
    indexing = true;
    errorMessage = null;
    phase = LibraryPhase.indexing;
    indexedCount = 0;
    notifyListeners();

    final collected = <MediaAsset>[];
    try {
      deviceAlbums = await _library.listAlbums();
      await for (final page in _library.pagedAllAssets(
        pageSize: LumaTokens.pageSize,
      )) {
        if (_disposed) return;
        collected.addAll(page);
        indexedCount = collected.length;
        _commitAssets(
          collected,
          derived: collected.length <= LumaTokens.pageSize,
        );
        if (collected.length == LumaTokens.pageSize ||
            collected.length % 400 == 0) {
          notifyListeners();
        }
      }
      _commitAssets(collected, derived: true);
      indexing = false;
      phase = collected.isEmpty ? LibraryPhase.empty : LibraryPhase.ready;
      notifyListeners();
      unawaited(_backfillSizes());
      unawaited(_loadAlbumMembership());
    } catch (error) {
      indexing = false;
      errorMessage = 'Could not read the photo library.';
      phase = collected.isEmpty ? LibraryPhase.error : LibraryPhase.ready;
      if (collected.isNotEmpty) _commitAssets(collected, derived: true);
      notifyListeners();
    }
  }

  void _commitAssets(List<MediaAsset> next, {required bool derived}) {
    _assets = List<MediaAsset>.unmodifiable(next);
    _byId = {for (final asset in next) asset.id: asset};
    if (derived) _recomputeDerived();
  }

  void _recomputeDerived() {
    final visible = visibleAssets;
    moments = clusterMoments(visible);
    categories = visibleCategories(visible);
    duplicateGroups = findExactDuplicates(visible);
    health = buildHealth(
      visible,
      duplicateCandidateCount: duplicateGroups.fold<int>(
        0,
        (sum, g) => sum + g.items.length,
      ),
    );
  }

  Future<void> _backfillSizes() async {
    final gen = ++_backfillGeneration;
    sizing = true;
    notifyListeners();
    var dirty = 0;
    final updated = [..._assets];
    for (var i = 0; i < updated.length; i++) {
      if (_disposed || gen != _backfillGeneration) return;
      final asset = updated[i];
      if (asset.fileSizeBytes != null) continue;
      final size = await _library.fileSizeBytes(asset.id);
      if (size == null) continue;
      updated[i] = asset.copyWith(fileSizeBytes: size);
      dirty++;
      if (dirty % 24 == 0) {
        _commitAssets(updated, derived: true);
        notifyListeners();
      }
    }
    sizing = false;
    _commitAssets(updated, derived: true);
    notifyListeners();
  }

  Future<void> _loadAlbumMembership() async {
    final map = <String, List<String>>{};
    for (final album in deviceAlbums) {
      if (album.isAll) continue;
      try {
        map[album.id] = await _library.assetIdsForAlbum(album.id);
      } catch (_) {
        map[album.id] = const [];
      }
    }
    _albumIdToAssets = map;
    notifyListeners();
  }

  List<MediaAsset> assetsInAlbum(MediaAlbum album) {
    if (!album.isFromDevice) {
      final collection = collections.where((c) => c.id == album.id);
      if (collection.isEmpty) return const [];
      return assetsByIds(collection.first.assetIds);
    }
    if (album.isAll) return visibleAssets;
    final ids = _albumIdToAssets[album.id];
    if (ids == null) return const [];
    return assetsByIds(ids);
  }

  List<DateSection> sectionsFor(List<MediaAsset> list) => groupByDay(list);

  List<MediaAsset> search(String query) {
    final intent = parseSearchQuery(query);
    return applySearch(
      visibleAssets,
      intent,
      albums: deviceAlbums,
      albumAssetIds: (id) => _albumIdToAssets[id] ?? const [],
    );
  }

  Future<void> toggleFavorite(String id) async {
    final asset = _byId[id];
    if (asset == null) return;
    final next = !asset.isFavorite;
    try {
      await _library.favorite(id, next);
      _replaceAsset(asset.copyWith(isFavorite: next));
    } on LumaException {
      rethrow;
    } catch (error) {
      throw LumaException('Could not update favorite.', cause: error);
    }
  }

  Future<List<String>> delete(List<String> ids) async {
    final deleted = await _library.deleteIds(ids);
    if (deleted.isEmpty) return deleted;
    final remaining = _assets
        .where((asset) => !deleted.contains(asset.id))
        .toList();
    _commitAssets(remaining, derived: true);
    notifyListeners();
    return deleted;
  }

  Future<void> scanSimilar() async {
    if (scanningSimilar) return;
    scanningSimilar = true;
    notifyListeners();
    final updated = [..._assets];
    for (var i = 0; i < updated.length; i++) {
      if (_disposed) return;
      final asset = updated[i];
      if (asset.perceptualHash != null) continue;
      final bytes = await _library.thumbnailBytes(asset.id, size: 64);
      if (bytes == null) continue;
      final hash = await perceptualHashFromBytes(bytes);
      if (hash == null) continue;
      updated[i] = asset.copyWith(perceptualHash: hash);
      if (i % 20 == 0) {
        _commitAssets(updated, derived: false);
        notifyListeners();
      }
    }
    _commitAssets(updated, derived: false);
    final visible = visibleAssets;
    duplicateGroups = mergeDuplicateGroups(
      findExactDuplicates(visible),
      findNearDuplicates(visible),
    );
    health = buildHealth(
      visible,
      duplicateCandidateCount: duplicateGroups.fold<int>(
        0,
        (sum, g) => sum + g.items.length,
      ),
    );
    scanningSimilar = false;
    notifyListeners();
  }

  Future<void> createCollection(String name, List<String> ids) async {
    final collection = LumaCollection(
      id: 'luma-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      assetIds: ids,
    );
    await _settings.saveCollections([..._settings.collections, collection]);
    notifyListeners();
  }

  Future<void> addToCollection(String collectionId, List<String> ids) async {
    final next = [
      for (final c in _settings.collections)
        if (c.id == collectionId)
          c.copyWith(assetIds: {...c.assetIds, ...ids}.toList())
        else
          c,
    ];
    await _settings.saveCollections(next);
    notifyListeners();
  }

  void _replaceAsset(MediaAsset asset) {
    final next = [
      for (final item in _assets)
        if (item.id == asset.id) asset else item,
    ];
    _commitAssets(next, derived: true);
    notifyListeners();
  }

  void _onSettingsChanged() {
    _recomputeDerived();
    notifyListeners();
  }

  void _onLibraryChanged() {
    _changeDebounce?.cancel();
    _changeDebounce = Timer(const Duration(milliseconds: 800), () {
      if (permission.hasAccess) unawaited(loadLibrary());
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _changeDebounce?.cancel();
    _backfillGeneration++;
    _settings.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _library.removeChangeListener(_onLibraryChanged);
    super.dispose();
  }
}
