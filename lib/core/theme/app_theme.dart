import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTheme defines Material 3 Light and Dark ThemeData for NoteNest AI.
class AppTheme {
  AppTheme._();

  /// Dark Theme tailored for NoteNest AI deep ambient aesthetic.
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final poppinsTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgGradientBottom,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.ambientPurpleGlow,
        secondary: AppColors.cyanAccentStart,
        surface: AppColors.bgGradientMiddle,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: poppinsTheme.copyWith(
        headlineLarge: poppinsTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: poppinsTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        bodyMedium: poppinsTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
    );
  }

  /// Light Theme configured for NoteNest AI Material 3.
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final poppinsTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C2BFF),
        secondary: Color(0xFF00C2FF),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Color(0xFF160636),
      ),
      textTheme: poppinsTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }
}
