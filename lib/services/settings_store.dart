import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import '../models/media_album.dart';

class LumaCollection {
  const LumaCollection({
    required this.id,
    required this.name,
    required this.assetIds,
  });

  final String id;
  final String name;
  final List<String> assetIds;

  MediaAlbum asAlbum(List<String> existingIds) {
    final ids = assetIds.where(existingIds.contains).toList();
    return MediaAlbum(
      id: id,
      name: name,
      count: ids.length,
      coverId: ids.isEmpty ? null : ids.first,
      isFromDevice: false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'assetIds': assetIds,
  };

  factory LumaCollection.fromJson(Map<String, dynamic> json) {
    return LumaCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      assetIds: (json['assetIds'] as List<dynamic>).cast<String>(),
    );
  }

  LumaCollection copyWith({String? name, List<String>? assetIds}) {
    return LumaCollection(
      id: id,
      name: name ?? this.name,
      assetIds: assetIds ?? this.assetIds,
    );
  }
}

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'luma.theme';
  static const _gridKey = 'luma.grid';
  static const _glassKey = 'luma.glass';
  static const _motionKey = 'luma.reduceMotion';
  static const _videosKey = 'luma.includeVideos';
  static const _collectionsKey = 'luma.collections';

  AppSettings settings = AppSettings(glass: defaultGlassLevel());
  List<LumaCollection> collections = const [];

  void load() {
    settings = AppSettings(
      theme: _readEnum(
        ThemePreference.values,
        _themeKey,
        ThemePreference.system,
      ),
      grid: _readEnum(GridDensity.values, _gridKey, GridDensity.regular),
      glass: _readEnum(GlassLevel.values, _glassKey, defaultGlassLevel()),
      reduceMotion: _prefs.getBool(_motionKey) ?? false,
      includeVideos: _prefs.getBool(_videosKey) ?? true,
    );
    final raw = _prefs.getString(_collectionsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        collections = [
          for (final item in list)
            LumaCollection.fromJson(item as Map<String, dynamic>),
        ];
      } catch (_) {
        collections = const [];
      }
    }
    notifyListeners();
  }

  Future<void> update(AppSettings next) async {
    settings = next;
    notifyListeners();
    await _prefs.setInt(_themeKey, next.theme.index);
    await _prefs.setInt(_gridKey, next.grid.index);
    await _prefs.setInt(_glassKey, next.glass.index);
    await _prefs.setBool(_motionKey, next.reduceMotion);
    await _prefs.setBool(_videosKey, next.includeVideos);
  }

  Future<void> saveCollections(List<LumaCollection> next) async {
    collections = next;
    notifyListeners();
    await _prefs.setString(
      _collectionsKey,
      jsonEncode([for (final c in next) c.toJson()]),
    );
  }

  T _readEnum<T>(List<T> values, String key, T fallback) {
    final index = _prefs.getInt(key);
    if (index == null || index < 0 || index >= values.length) return fallback;
    return values[index];
  }
}

GlassLevel defaultGlassLevel() {
  if (kIsWeb) return GlassLevel.reduced;
  return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS
      ? GlassLevel.full
      : GlassLevel.reduced;
}
