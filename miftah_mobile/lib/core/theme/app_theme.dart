import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 32),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 24),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 20),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16),
      ),
      appBarTheme: _appBarTheme(AppColors.background, AppColors.textPrimary),
      elevatedButtonTheme: _elevatedButtonTheme(),
      cardTheme: _cardTheme(AppColors.surface),
      inputDecorationTheme: _inputTheme(AppColors.surfaceVariant, AppColors.textSecondary),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        brightness: Brightness.dark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, fontSize: 32),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, fontSize: 24),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, fontSize: 20),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimaryDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 14),
      ),
      appBarTheme: _appBarTheme(AppColors.backgroundDark, AppColors.textPrimaryDark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      cardTheme: _cardTheme(AppColors.surfaceDark),
      inputDecorationTheme: _inputTheme(AppColors.surfaceVariantDark, AppColors.textSecondaryDark),
    );
  }

  static AppBarTheme _appBarTheme(Color bg, Color text) => AppBarTheme(
    backgroundColor: bg,
    foregroundColor: text,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: GoogleFonts.outfit(color: text, fontWeight: FontWeight.bold, fontSize: 20),
    iconTheme: IconThemeData(color: text),
  );

  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  );

  static CardThemeData _cardTheme(Color color) => CardThemeData(
    color: color,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withOpacity(0.05)),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  static InputDecorationTheme _inputTheme(Color fill, Color hint) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    hintStyle: GoogleFonts.inter(color: hint, fontSize: 14),
  );
}
