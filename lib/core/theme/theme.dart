import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// DAKKHO Academy — Theme
///
/// Two themes:
///   - `darkTheme` (default): slate-900 backgrounds, glassmorphism cards, sky-500 primary
///   - `lightTheme`: sky-50 backgrounds, white glass cards (user-toggleable)
///
/// Both themes use Material 3 (Material You) for shape system + elevation.
/// Custom glassmorphism is layered on top via GlassCard widget (see shared/widgets/).

class DakkhoTheme {
  DakkhoTheme._();

  // ─── Dark Theme (default) ───
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DakkhoColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: DakkhoColors.primary,
      onPrimary: Colors.white,
      secondary: DakkhoColors.accent,
      onSecondary: Colors.white,
      tertiary: DakkhoColors.purple,
      onTertiary: Colors.white,
      error: DakkhoColors.danger,
      onError: Colors.white,
      surface: DakkhoColors.surface,
      onSurface: DakkhoColors.textPrimary,
      surfaceContainerHighest: DakkhoColors.surfaceLight,
      outline: DakkhoColors.textMuted,
      outlineVariant: DakkhoColors.glassCardBorder,
    ),
    primaryColor: DakkhoColors.primary,
    canvasColor: DakkhoColors.bgDark,
    cardColor: DakkhoColors.surface,
    dividerColor: DakkhoColors.glassCardBorder,

    // ─── Text Theme ───
    textTheme: const TextTheme(
      displayLarge: DakkhoTypography.displayLarge,
      displayMedium: DakkhoTypography.displayMedium,
      displaySmall: DakkhoTypography.displaySmall,
      headlineLarge: DakkhoTypography.headlineLarge,
      headlineMedium: DakkhoTypography.headlineMedium,
      headlineSmall: DakkhoTypography.headlineSmall,
      bodyLarge: DakkhoTypography.bodyLarge,
      bodyMedium: DakkhoTypography.bodyMedium,
      bodySmall: DakkhoTypography.bodySmall,
      labelLarge: DakkhoTypography.labelLarge,
      labelMedium: DakkhoTypography.labelMedium,
      labelSmall: DakkhoTypography.labelSmall,
    ),

    // ─── App Bar ───
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DakkhoColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: DakkhoColors.textPrimary, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // ─── Card ───
    cardTheme: CardThemeData(
      color: DakkhoColors.glassCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // ─── Elevated Button ───
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DakkhoColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: ['NotoSansBengali'],
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // ─── Text Button ───
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DakkhoColors.primary,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: ['NotoSansBengali'],
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ─── Outlined Button ───
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DakkhoColors.textPrimary,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // ─── Icon Theme ───
    iconTheme: const IconThemeData(
      color: DakkhoColors.textPrimary,
      size: 24,
    ),

    // ─── Input Decoration ───
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DakkhoColors.surfaceLight,
      hintStyle: const TextStyle(color: DakkhoColors.textSecondary),
      labelStyle: const TextStyle(color: DakkhoColors.textSecondary),
      prefixIconColor: DakkhoColors.textSecondary,
      suffixIconColor: DakkhoColors.textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DakkhoColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DakkhoColors.danger, width: 1.5),
      ),
    ),

    // ─── Bottom Navigation Bar ───
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DakkhoColors.glassSidebar,
      selectedItemColor: DakkhoColors.primary,
      unselectedItemColor: DakkhoColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
    ),

    // ─── Navigation Bar (Material 3) ───
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DakkhoColors.glassSidebar,
      indicatorColor: DakkhoColors.primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 11,
        fontWeight: FontWeight.w600,
      )),
      height: 72,
    ),

    // ─── Drawer (Sidebar) ───
    drawerTheme: const DrawerThemeData(
      backgroundColor: DakkhoColors.glassSidebar,
      width: 320,
    ),

    // ─── Divider ───
    dividerTheme: const DividerThemeData(
      color: DakkhoColors.glassCardBorder,
      thickness: 1,
      space: 1,
    ),

    // ─── Snackbar ───
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DakkhoColors.surfaceLight,
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        color: DakkhoColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ─── Dialog ───
    dialogTheme: DialogThemeData(
      backgroundColor: DakkhoColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: DakkhoColors.textPrimary,
      ),
    ),

    // ─── Bottom Sheet ───
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DakkhoColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // ─── Floating Action Button ───
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DakkhoColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ─── Chip ───
    chipTheme: ChipThemeData(
      backgroundColor: DakkhoColors.surfaceLight,
      selectedColor: DakkhoColors.primary,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DakkhoColors.textPrimary,
      ),
      side: const BorderSide(color: DakkhoColors.glassCardBorder, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // ─── Progress Indicators ───
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DakkhoColors.primary,
      linearTrackColor: DakkhoColors.surfaceLight,
    ),

    // ─── Switch ───
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DakkhoColors.primary;
        return DakkhoColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DakkhoColors.primary.withValues(alpha: 0.4);
        return DakkhoColors.surfaceLighter;
      }),
    ),

    // ─── Slider ───
    sliderTheme: SliderThemeData(
      activeTrackColor: DakkhoColors.primary,
      inactiveTrackColor: DakkhoColors.surfaceLighter,
      thumbColor: DakkhoColors.primary,
      overlayColor: DakkhoColors.primary.withValues(alpha: 0.2),
    ),

    // ─── Tab Bar ───
    tabBarTheme: TabBarThemeData(
      labelColor: DakkhoColors.primary,
      unselectedLabelColor: DakkhoColors.textSecondary,
      indicatorColor: DakkhoColors.primary,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),

    // ─── List Tile ───
    listTileTheme: const ListTileThemeData(
      iconColor: DakkhoColors.textSecondary,
      textColor: DakkhoColors.textPrimary,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: DakkhoColors.textPrimary,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: DakkhoColors.textSecondary,
      ),
    ),

    // ─── Tooltip ───
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: DakkhoColors.surfaceLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: ['NotoSansBengali'],
        fontSize: 12,
        color: DakkhoColors.textPrimary,
      ),
    ),

    // ─── Scrollbar ───
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(DakkhoColors.primary.withValues(alpha: 0.3)),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      radius: const Radius.circular(100),
      thickness: WidgetStateProperty.all(6),
      thumbVisibility: WidgetStateProperty.all(false),
    ),

    // ─── Splash Factory (no ripple on iOS-style buttons) ───
    splashFactory: InkSparkle.splashFactory,
    splashColor: DakkhoColors.primary.withValues(alpha: 0.1),
    highlightColor: DakkhoColors.primary.withValues(alpha: 0.05),

    // ─── Visual Density ───
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // ─── Light Theme ───
  static ThemeData lightTheme = darkTheme.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: DakkhoColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: DakkhoColors.primary,
      onPrimary: Colors.white,
      secondary: DakkhoColors.accent,
      onSecondary: Colors.white,
      tertiary: DakkhoColors.purple,
      onTertiary: Colors.white,
      error: DakkhoColors.danger,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      outline: DakkhoColors.textMuted,
      outlineVariant: Color(0xFFE2E8F0),
    ),
    canvasColor: DakkhoColors.bgLight,
    cardColor: Colors.white,
    // (Rest inherits sensibly from dark theme for now — most users stay in dark mode)
  );
}
