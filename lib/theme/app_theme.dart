import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Centralized Design System Tokens for the Handelak Brand (Strict Purple & Orange Identity)
class AppColors {
  // Primary Brand Colors (Handelak Identity Specification)
  static const Color primaryPurple = Color(0xFF6B4EFF);  // Electric Apple Purple (#6B4EFF)
  static const Color hoverPurple = Color(0xFF5532E0);    // Deep Hover Purple (#5532E0)
  static const Color primaryOrange = Color(0xFFFF5008);  // Vibrant Saffron Orange (#FF5008)
  static const Color lightPurple = Color(0xFFF1EBFF);   // Soft Light Purple (#F1EBFF)
  static const Color lightOrange = Color(0xFFFFF0E8);   // Light Orange (#FFF0E8)
  
  // Neutral Palette
  static const Color backgroundLight = Colors.white;     // Content Background (#FFFFFF)
  static const Color surfaceMuted = Color(0xFFF5F3FA);   // Subtle Neutral Surface
  static const Color cardSurface = Colors.white;
  static const Color darkGray = Color(0xFF333333);      // Dark Gray (#333333) - Readable Text
  static const Color mediumGray = Color(0xFF757575);    // Medium Gray (#757575) - Captions
  static const Color borderLight = Color(0xFFE2DCF2);   // Soft Neutral Border
  
  // Mapped Strictly to Purple & Orange Identity
  static const Color nileTeal = primaryPurple;
  static const Color terracotta = primaryOrange;
  static const Color papyrusGold = primaryOrange;       // Mapped to Orange Highlight
  static const Color desertSand = lightPurple;
  static const Color charcoal = darkGray;
  static const Color textMuted = mediumGray;
  static const Color seaTurquoise = primaryPurple;
  
  // Semantic Status Colors (Purple & Orange Mapped)
  static const Color verifiedGreen = primaryPurple;      // Verified Badge (Purple)
  static const Color starYellow = primaryOrange;         // Star Ratings (Orange)
  static const Color alertAmber = primaryOrange;         // Schedule Warnings (Orange)
  
  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF1B0054);
  static const Color darkCardSurface = Color(0xFF260078);
  static const Color darkBorder = Color(0xFF3D00B0);
}

class AppGradients {
  // Royal Indigo & Electric Purple Gradient
  static const LinearGradient royalPurpleGradient = LinearGradient(
    colors: [
      Color(0xFF7A52FF), // Vibrant Electric Purple
      Color(0xFF5324D6), // Deep Royal Indigo
      Color(0xFF3811A8), // Lapis Amethyst
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sunset Saffron Orange Gradient
  static const LinearGradient sunsetOrangeGradient = LinearGradient(
    colors: [
      Color(0xFFFF6E40), // Bright Tangerine
      Color(0xFFFF5008), // Primary Handelak Orange
      Color(0xFFE64A19), // Deep Terracotta
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Apple Crystal Liquid Glass Dock Gradient (Ultra-Transparent)
  static LinearGradient glassNavbarGradient = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.32),
      Colors.white.withValues(alpha: 0.18),
      Colors.white.withValues(alpha: 0.08),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.5, 1.0],
  );

  // Orange Highlight Accent Gradient (Mapped to Sunset Orange)
  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [
      Color(0xFFFF6E40),
      Color(0xFFFF5008),
      Color(0xFFE64A19),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Lavender Gradient for Chips & Cards
  static const LinearGradient softLavenderGradient = LinearGradient(
    colors: [
      Color(0xFFF8F5FF),
      Color(0xFFF1EBFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPurple,
        primary: AppColors.primaryPurple,
        secondary: AppColors.primaryOrange,
        tertiary: AppColors.primaryOrange,
        surface: AppColors.cardSurface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkGray,
      ),
      fontFamily: 'Roboto',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shadowColor: AppColors.primaryPurple.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.8),
        ),
        hintStyle: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPurple,
        selectedColor: AppColors.primaryPurple,
        secondarySelectedColor: AppColors.primaryOrange,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkGray,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.mediumGray,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }
}
