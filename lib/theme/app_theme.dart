import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette: Egyptian-inspired luxury & modern polish
  static const Color nileTeal = Color(0xFF0A2540);      // Deep Nile Blue/Teal
  static const Color desertSand = Color(0xFFF8F5EE);    // Warm Ivory/Desert Sand
  static const Color terracotta = Color(0xFFC85A32);    // Egyptian Terracotta Accent
  static const Color papyrusGold = Color(0xFFD4AF37);   // Pharaonic Gold
  static const Color charcoal = Color(0xFF1A1A1A);      // Crisp Text/Charcoal
  static const Color seaTurquoise = Color(0xFF00A896);  // Red Sea Turquoise
  
  // UI Functional Colors
  static const Color backgroundLight = Color(0xFFFBF9F5);
  static const Color cardSurface = Colors.white;
  static const Color borderLight = Color(0xFFE8E2D5);
  static const Color textMuted = Color(0xFF6E7C8C);
  static const Color verifiedGreen = Color(0xFF2E7D32);
  static const Color starYellow = Color(0xFFFFB300);
  
  // Dark Mode Adjustments
  static const Color darkBackground = Color(0xFF08131E);
  static const Color darkCardSurface = Color(0xFF102030);
  static const Color darkBorder = Color(0xFF1D354D);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.nileTeal,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.nileTeal,
        primary: AppColors.nileTeal,
        secondary: AppColors.terracotta,
        tertiary: AppColors.papyrusGold,
        surface: AppColors.cardSurface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.charcoal,
      ),
      fontFamily: 'Roboto', // Fallback cleanly if custom fonts are loading
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.charcoal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 2,
        shadowColor: AppColors.nileTeal.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nileTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.nileTeal,
          side: const BorderSide(color: AppColors.nileTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.nileTeal, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.desertSand,
        selectedColor: AppColors.nileTeal.withValues(alpha: 0.12),
        secondarySelectedColor: AppColors.nileTeal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        labelStyle: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.nileTeal,
        unselectedItemColor: AppColors.textMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
