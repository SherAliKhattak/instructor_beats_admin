import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instructor_beats_admin/theme/app_colors.dart';

/// Material 3 themes: consumer-style light (auth) + dark dashboard (admin shell).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.title,
        outline: AppColors.fieldBorder,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final poppinsText = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.title,
      displayColor: AppColors.title,
    );

    return base.copyWith(
      textTheme: poppinsText,
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme)
          .apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.title,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.title,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.skip),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: AppColors.playlistCardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.fieldBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.fieldBorder),
    );
  }

  /// Dark admin dashboard (reference: Smart HR style).
  static ThemeData get dashboardDark {
    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withValues(alpha: 0.12),
      secondary: DashColors.blue,
      onSecondary: Colors.white,
      surface: DashColors.surface,
      onSurface: DashColors.textPrimary,
      onSurfaceVariant: DashColors.textMuted,
      surfaceContainerHighest: AppColors.fieldFill,
      outline: DashColors.border,
      error: DashColors.red,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: DashColors.canvas,
    );

    final poppinsText = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: DashColors.textPrimary,
      displayColor: DashColors.textPrimary,
    );

    return base.copyWith(
      textTheme: poppinsText,
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme)
          .apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DashColors.surface,
        foregroundColor: DashColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: DashColors.sidebar,
        selectedIconTheme: const IconThemeData(color: DashColors.green),
        unselectedIconTheme: const IconThemeData(color: DashColors.textMuted),
        selectedLabelTextStyle: GoogleFonts.poppins(
          color: DashColors.green,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: GoogleFonts.poppins(
          color: DashColors.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        indicatorColor: DashColors.green.withValues(alpha: 0.12),
      ),
      cardTheme: CardThemeData(
        color: DashColors.card,
        elevation: 0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: DashColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: DashColors.border),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DashColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DashColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DashColors.green, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          color: DashColors.textMuted.withValues(alpha: 0.8),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(DashColors.sidebar),
        headingTextStyle: GoogleFonts.poppins(
          color: DashColors.textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        dataTextStyle: GoogleFonts.poppins(
          color: DashColors.textPrimary,
          fontSize: 14,
        ),
        dividerThickness: 1,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DashColors.border)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DashColors.card,
        side: const BorderSide(color: DashColors.border),
        labelStyle: GoogleFonts.poppins(
          color: DashColors.textPrimary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DashColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: DashColors.border),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: DashColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.poppins(color: DashColors.textMuted),
      ),
    );
  }
}
