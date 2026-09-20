import 'package:flutter/material.dart';

/// CraftMitra color tokens extracted from Stitch design system.
/// Design system: "CraftMitra Earth & Dignity"
class AppColors {
  AppColors._();

  // ─── Core Brand Colors ───
  static const Color primary = Color(0xFF9F3C16);
  static const Color primaryContainer = Color(0xFFBF542C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);
  static const Color primaryFixed = Color(0xFFFFDBCF);
  static const Color primaryFixedDim = Color(0xFFFFB59C);
  static const Color onPrimaryFixed = Color(0xFF390C00);
  static const Color onPrimaryFixedVariant = Color(0xFF822801);

  static const Color secondary = Color(0xFF2A6A48);
  static const Color secondaryContainer = Color(0xFFACEEC4);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF2F6E4C);
  static const Color secondaryFixed = Color(0xFFAFF1C6);
  static const Color secondaryFixedDim = Color(0xFF93D5AC);
  static const Color onSecondaryFixed = Color(0xFF002111);
  static const Color onSecondaryFixedVariant = Color(0xFF0A5132);

  static const Color tertiary = Color(0xFF8D4B00);
  static const Color tertiaryContainer = Color(0xFFB15F00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);
  static const Color tertiaryFixed = Color(0xFFFFDCC3);
  static const Color tertiaryFixedDim = Color(0xFFFFB77D);
  static const Color onTertiaryFixed = Color(0xFF2F1500);
  static const Color onTertiaryFixedVariant = Color(0xFF6E3900);

  // ─── Surface & Background ───
  static const Color background = Color(0xFFFFF8F5);
  static const Color surface = Color(0xFFFFF8F5);
  static const Color surfaceBright = Color(0xFFFFF8F5);
  static const Color surfaceDim = Color(0xFFEDD5C8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF1EA);
  static const Color surfaceContainer = Color(0xFFFFEADF);
  static const Color surfaceContainerHigh = Color(0xFFFCE3D6);
  static const Color surfaceContainerHighest = Color(0xFFF6DED1);
  static const Color surfaceTint = Color(0xFFA23E18);
  static const Color surfaceVariant = Color(0xFFF6DED1);

  // ─── On-Surface & Text ───
  static const Color onSurface = Color(0xFF251911);
  static const Color onSurfaceVariant = Color(0xFF57423B);
  static const Color onBackground = Color(0xFF251911);

  // ─── Outline & Borders ───
  static const Color outline = Color(0xFF8A726A);
  static const Color outlineVariant = Color(0xFFDEC0B7);

  // ─── Inverse ───
  static const Color inverseSurface = Color(0xFF3C2D25);
  static const Color inverseOnSurface = Color(0xFFFFEDE4);
  static const Color inversePrimary = Color(0xFFFFB59C);

  // ─── Error ───
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Semantic / Functional Colors ───
  /// Mitti Terracotta brand accent (used in some gradient overlays)
  static const Color mittiTerracotta = Color(0xFFC85A32);

  /// Neem Leaf Green for growth indicators
  static const Color neemGreen = Color(0xFF3B7A57);

  /// Haldi Amber Gold for AI / opportunity highlights
  static const Color haldiGold = Color(0xFFD97706);

  /// Deep Chullah Brown for neutral text
  static const Color chullahBrown = Color(0xFF2B1E16);

  /// Kora Raw Cotton canvas
  static const Color koraCanvas = Color(0xFFFBF8F3);

  /// Elevated card white
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Recessed surface
  static const Color recessedSurface = Color(0xFFF4EFE6);

  /// Border color for cards
  static const Color cardBorder = Color(0xFFEADFD0);

  // ─── Chart Colors ───
  static const Color chartBarLight = Color(0xFFDEC0B7);
  static const Color chartBarMid = Color(0xFFBF542C);
  static const Color chartBarDark = Color(0xFF9F3C16);

  // ─── Badge / Tag Colors ───
  static const Color aiRecommendBg = Color(0xFFFFFBEB);
  static const Color aiRecommendText = Color(0xFFB45309);
  static const Color aiRecommendBorder = Color(0xFFFDE68A);
  static const Color aiEnhancedBg = Color(0xFFECFDF5);
  static const Color aiEnhancedText = Color(0xFF047857);
  static const Color aiEnhancedBorder = Color(0xFFA7F3D0);
}
