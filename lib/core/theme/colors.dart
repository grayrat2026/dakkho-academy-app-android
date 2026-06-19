import 'package:flutter/material.dart';

/// DAKKHO Academy — Color Palette
///
/// Matches the dakkho-student-app web app's Tailwind CSS variables exactly.
/// Source: student-app/src/app/globals.css
///
/// Dark mode is the default (per spec). Light mode is supported for users
/// who explicitly enable it, but the app opens in dark by default.

class DakkhoColors {
  DakkhoColors._();

  // ─── Brand ───
  static const Color primary = Color(0xFF0EA5E9);        // sky-500
  static const Color primaryDark = Color(0xFF2563EB);    // blue-600
  static const Color accent = Color(0xFF10B981);         // emerald-500
  static const Color warning = Color(0xFFF59E0B);        // amber-500
  static const Color danger = Color(0xFFEF4444);         // red-500
  static const Color purple = Color(0xFF8B5CF6);         // violet-500

  // ─── Dark Mode Backgrounds (slate family) ───
  static const Color bgDark = Color(0xFF0C1222);         // custom dark navy
  static const Color bgDarker = Color(0xFF020617);       // slate-950
  static const Color surface = Color(0xFF0F172A);        // slate-900
  static const Color surfaceLight = Color(0xFF1E293B);   // slate-800
  static const Color surfaceLighter = Color(0xFF334155); // slate-700

  // ─── Text ───
  static const Color textPrimary = Color(0xFFF0F9FF);    // sky-50
  static const Color textSecondary = Color(0xFF94A3B8);  // slate-400
  static const Color textMuted = Color(0xFF64748B);      // slate-500

  // ─── Glassmorphism (matches .dark .glass-card CSS) ───
  static const Color glassCardBg = Color(0xB31E293B);       // slate-800 @ 70% opacity (0xB3 = 179/255 ≈ 0.7)
  static const Color glassCardBorder = Color(0x1AFFFFFF);   // white @ 10%
  static const Color glassCardShadow = Color(0x1A0EA5E9);   // sky-500 @ 10%

  static const Color glassSidebar = Color(0xD91E293B);      // slate-800 @ 85% (0xD9 ≈ 217/255 ≈ 0.85)

  // ─── Light Mode Backgrounds ───
  static const Color bgLight = Color(0xFFF0F9FF);        // sky-50
  static const Color surfaceLightMode = Color(0xFFFFFFFF);
  static const Color glassCardBgLight = Color(0xB3FFFFFF); // white @ 70%

  // ─── Chart Colors (matches globals.css) ───
  static const Color chart1 = Color(0xFF0EA5E9);
  static const Color chart2 = Color(0xFF10B981);
  static const Color chart3 = Color(0xFFF59E0B);
  static const Color chart4 = Color(0xFF8B5CF6);
  static const Color chart5 = Color(0xFFEF4444);

  // ─── Status Colors ───
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // ─── Gradient Definitions ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF0EA5E9)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  /// Course card thumbnail gradients (cycled by course ID hash)
  static const List<List<Color>> courseGradients = [
    [Color(0xFF0EA5E9), Color(0xFF2563EB)],   // sky → blue
    [Color(0xFF10B981), Color(0xFF0EA5E9)],   // emerald → sky
    [Color(0xFFF59E0B), Color(0xFFEF4444)],   // amber → red
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],   // violet → pink
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],   // cyan → blue
    [Color(0xFF14B8A6), Color(0xFF22C55E)],   // teal → green
  ];

  /// Get a gradient for a course based on its ID
  static List<Color> courseGradientFor(String id) {
    final hash = id.hashCode.abs();
    return courseGradients[hash % courseGradients.length];
  }
}
