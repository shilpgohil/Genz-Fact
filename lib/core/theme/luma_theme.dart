import 'package:flutter/material.dart';

import 'luma_colors.dart';
import 'luma_tokens.dart';

TextTheme lumaTextTheme(LumaColors colors, TextTheme base) {
  return base.copyWith(
    displayLarge: TextStyle(
      fontFamily: 'serif',
      fontSize: 44,
      height: 1.05,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
      color: colors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'serif',
      fontSize: 32,
      height: 1.1,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.4,
      color: colors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: colors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: colors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: colors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: colors.textTertiary,
    ),
  );
}

ThemeData lumaTheme({required Brightness brightness}) {
  final colors = brightness == Brightness.dark
      ? LumaColors.dark
      : LumaColors.light;
  final base = brightness == Brightness.dark
      ? ThemeData.dark()
      : ThemeData.light();
  final text = lumaTextTheme(colors, base.textTheme);

  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: colors.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: brightness == Brightness.dark
          ? const Color(0xFF1A1916)
          : colors.surface,
      secondary: colors.accent,
      onSecondary: colors.textPrimary,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    ),
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
    splashColor: colors.accentSoft,
    highlightColor: Colors.transparent,
    dividerColor: colors.hairline,
    iconTheme: IconThemeData(
      color: colors.textPrimary,
      size: LumaTokens.iconMd,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: colors.textPrimary,
      titleTextStyle: text.titleLarge,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LumaTokens.radiusSheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.bgElevated,
      contentTextStyle: text.bodyMedium?.copyWith(color: colors.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    extensions: [colors],
  );
}
