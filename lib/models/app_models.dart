import 'media_asset.dart';

enum LumaPermission {
  unknown,
  notDetermined,
  denied,
  restricted,
  limited,
  authorized,
}

extension LumaPermissionX on LumaPermission {
  bool get hasAccess =>
      this == LumaPermission.authorized || this == LumaPermission.limited;
}

enum LibraryPhase { booting, needsPermission, indexing, ready, empty, error }

enum ThemePreference { system, light, dark }

enum GridDensity { comfortable, regular, compact }

enum GlassLevel { full, reduced, off }

class AppSettings {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.grid = GridDensity.regular,
    this.glass = GlassLevel.reduced,
    this.reduceMotion = false,
    this.includeVideos = true,
  });

  final ThemePreference theme;
  final GridDensity grid;
  final GlassLevel glass;
  final bool reduceMotion;
  final bool includeVideos;

  AppSettings copyWith({
    ThemePreference? theme,
    GridDensity? grid,
    GlassLevel? glass,
    bool? reduceMotion,
    bool? includeVideos,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      grid: grid ?? this.grid,
      glass: glass ?? this.glass,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      includeVideos: includeVideos ?? this.includeVideos,
    );
  }

  int columnsFor({required bool landscape}) {
    final base = switch (grid) {
      GridDensity.comfortable => 2,
      GridDensity.regular => 3,
      GridDensity.compact => 4,
    };
    return landscape ? (base + 1).clamp(2, 5) : base;
  }
}

class SearchIntent {
  const SearchIntent({
    this.raw = '',
    this.year,
    this.month,
    this.day,
    this.relativeDays,
    this.relativeSingleDay = false,
    this.kind,
    this.screenshotsOnly = false,
    this.favoritesOnly = false,
    this.largeOnly = false,
    this.albumQuery,
    this.unrecognized = const [],
  });

  final String raw;
  final int? year;
  final int? month;
  final int? day;

  /// If set, keep assets captured on/after today - [relativeDays].
  final int? relativeDays;

  /// When true, only that calendar day is kept (yesterday/today), not a range.
  final bool relativeSingleDay;
  final MediaKind? kind;
  final bool screenshotsOnly;
  final bool favoritesOnly;
  final bool largeOnly;
  final String? albumQuery;
  final List<String> unrecognized;

  bool get isEmpty =>
      raw.trim().isEmpty &&
      year == null &&
      month == null &&
      day == null &&
      relativeDays == null &&
      !relativeSingleDay &&
      kind == null &&
      !screenshotsOnly &&
      !favoritesOnly &&
      !largeOnly &&
      (albumQuery == null || albumQuery!.isEmpty);
}
