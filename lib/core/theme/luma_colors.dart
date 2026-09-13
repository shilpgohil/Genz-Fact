import 'package:flutter/material.dart';

@immutable
class LumaColors extends ThemeExtension<LumaColors> {
  const LumaColors({
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentSoft,
    required this.danger,
    required this.glassFill,
    required this.glassBorder,
    required this.scrim,
    required this.tilePlaceholder,
  });

  final Color bg;
  final Color bgElevated;
  final Color surface;
  final Color hairline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentSoft;
  final Color danger;
  final Color glassFill;
  final Color glassBorder;
  final Color scrim;
  final Color tilePlaceholder;

  static const LumaColors dark = LumaColors(
    bg: Color(0xFF070708),
    bgElevated: Color(0xFF101012),
    surface: Color(0xFF17171A),
    hairline: Color(0x26F4F1EA),
    textPrimary: Color(0xFFF4F1EA),
    textSecondary: Color(0xFFA39E94),
    textTertiary: Color(0xFF6F6B64),
    accent: Color(0xFFE4C39A),
    accentSoft: Color(0x33E4C39A),
    danger: Color(0xFFE85D4C),
    glassFill: Color(0x1AF4F1EA),
    glassBorder: Color(0x24F4F1EA),
    scrim: Color(0xCC070708),
    tilePlaceholder: Color(0xFF1C1C20),
  );

  static const LumaColors light = LumaColors(
    bg: Color(0xFFF3EFE8),
    bgElevated: Color(0xFFFAF7F1),
    surface: Color(0xFFFFFCF7),
    hairline: Color(0x261A1916),
    textPrimary: Color(0xFF1A1916),
    textSecondary: Color(0xFF6B655C),
    textTertiary: Color(0xFF8E877C),
    accent: Color(0xFF7A5428),
    accentSoft: Color(0x337A5428),
    danger: Color(0xFFC44536),
    glassFill: Color(0x99FFFCF7),
    glassBorder: Color(0x55FFFFFF),
    scrim: Color(0x99070708),
    tilePlaceholder: Color(0xFFE7E0D4),
  );

  @override
  LumaColors copyWith({
    Color? bg,
    Color? bgElevated,
    Color? surface,
    Color? hairline,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentSoft,
    Color? danger,
    Color? glassFill,
    Color? glassBorder,
    Color? scrim,
    Color? tilePlaceholder,
  }) {
    return LumaColors(
      bg: bg ?? this.bg,
      bgElevated: bgElevated ?? this.bgElevated,
      surface: surface ?? this.surface,
      hairline: hairline ?? this.hairline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      danger: danger ?? this.danger,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      scrim: scrim ?? this.scrim,
      tilePlaceholder: tilePlaceholder ?? this.tilePlaceholder,
    );
  }

  @override
  LumaColors lerp(ThemeExtension<LumaColors>? other, double t) {
    if (other is! LumaColors) return this;
    return LumaColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      tilePlaceholder: Color.lerp(tilePlaceholder, other.tilePlaceholder, t)!,
    );
  }
}

extension LumaColorsX on BuildContext {
  LumaColors get luma =>
      Theme.of(this).extension<LumaColors>() ?? LumaColors.dark;
}
