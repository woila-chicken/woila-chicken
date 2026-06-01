import 'package:flutter/material.dart';

class AppColors {
  static const primary       = Color(0xFF8B0000);
  static const primaryLight  = Color(0xFFCC0000);
  static const accent        = Color(0xFFF5C518);
  static const background    = Color(0xFFFAFAFA);
  static const surface       = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const success       = Color(0xFF2E7D32);
  static const warning       = Color(0xFFF57F17);
  static const error         = Color(0xFFC62828);
  static const divider       = Color(0xFFE0E0E0);
  static const clientColor   = Color(0xFF8B0000);
  static const eleveurColor  = Color(0xFFF5C518);
  static const adminColor    = Color(0xFF1A1A1A);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins', fontSize: 18,
        fontWeight: FontWeight.w600, color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary),
    ),
  );
}
