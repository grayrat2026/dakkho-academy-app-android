import 'package:flutter/material.dart';
import 'colors.dart';

/// DAKKHO Academy — Typography
///
/// Matches the web app's font choice: Nunito for everything.
/// Bengali uses Noto Sans Bengali (web app claims `lang="bn"` but ships English-only —
/// we're actually shipping Bengali support, so we need a proper Bengali font).
///
/// For Flutter, we bundle both fonts in assets/fonts/ and use fontFamilyFallback
/// so Latin text uses Nunito and Bengali text falls back to NotoSansBengali.

class DakkhoTypography {
  DakkhoTypography._();

  static const String primaryFont = 'Inter';        // For Latin text (modern, clean)
  static const String bengaliFont = 'NotoSansBengali';  // For Bengali script
  static const String monoFont = 'RobotoMono';      // For code/IDs

  /// Font family list — Flutter picks the first one that has the glyph.
  /// Inter covers Latin, NotoSansBengali covers Bengali.
  static const List<String> defaultFontFamilyFallback = [
    'Inter',
    'NotoSansBengali',
    'Roboto',
  ];

  // ─── Display (large page titles) ───
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: DakkhoColors.textPrimary,
  );

  // ─── Headlines (section titles) ───
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: DakkhoColors.textPrimary,
  );

  // ─── Body ───
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DakkhoColors.textSecondary,
  );

  // ─── Labels / Buttons ───
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: DakkhoColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: DakkhoColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: DakkhoColors.textSecondary,
  );

  // ─── Caption / Overline ───
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: DakkhoColors.textMuted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: defaultFontFamilyFallback,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 1.5,
    color: DakkhoColors.textSecondary,
  );
}

/// Text style helper for gradient text (matches .gradient-text CSS)
/// Usage: GradientText(text, style: DakkhoTypography.headlineLarge)
/// Gradient is applied by GradientText widget, not by TextStyle.
class DakkhoTextStyles {
  DakkhoTextStyles._();

  // Convenience aliases
  static const TextStyle displayL = DakkhoTypography.displayLarge;
  static const TextStyle displayM = DakkhoTypography.displayMedium;
  static const TextStyle displayS = DakkhoTypography.displaySmall;
  static const TextStyle headlineL = DakkhoTypography.headlineLarge;
  static const TextStyle headlineM = DakkhoTypography.headlineMedium;
  static const TextStyle headlineS = DakkhoTypography.headlineSmall;
  static const TextStyle bodyL = DakkhoTypography.bodyLarge;
  static const TextStyle bodyM = DakkhoTypography.bodyMedium;
  static const TextStyle bodyS = DakkhoTypography.bodySmall;
  static const TextStyle labelL = DakkhoTypography.labelLarge;
  static const TextStyle labelM = DakkhoTypography.labelMedium;
  static const TextStyle labelS = DakkhoTypography.labelSmall;
}
