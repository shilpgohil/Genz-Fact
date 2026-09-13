/// Design tokens. Widgets should not hard-code spacing, radii, or durations.
abstract final class LumaTokens {
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  static const double radiusTile = 12;
  static const double radiusCard = 18;
  static const double radiusSheet = 28;
  static const double radiusPill = 999;

  static const double blurFull = 18;
  static const double blurReduced = 8;

  static const double glassFillDark = 0.10;
  static const double glassFillLight = 0.62;
  static const double glassBorderDark = 0.14;
  static const double glassBorderLight = 0.55;

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 280);
  static const Duration motionSlow = Duration(milliseconds: 420);

  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double tapMin = 44;

  static const double gridGap = 3;
  static const int gridComfortable = 2;
  static const int gridRegular = 3;
  static const int gridCompact = 4;
  static const int gridMax = 5;

  static const int thumbnailGrid = 240;
  static const int thumbnailHero = 720;
  static const int previewViewer = 1600;

  static const int pageSize = 150;
  static const int largeImageBytes = 8 * 1024 * 1024;
  static const int largeVideoBytes = 50 * 1024 * 1024;
  static const Duration momentGap = Duration(hours: 4);
  static const Duration burstGap = Duration(milliseconds: 1500);
  static const int momentMinItems = 3;
  static const int nearDuplicateHamming = 8;
  static const int recentDays = 14;
}
