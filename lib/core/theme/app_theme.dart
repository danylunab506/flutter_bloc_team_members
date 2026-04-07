import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const primary = Color(0xFF00CDD6);
  static const primaryLight = Color(0xFF4DD9E0);
  static const primaryDark = Color(0xFF2E838A);

  // Accent
  static const accent = Color(0xFFFF8A65);

  // Backgrounds
  static const background = Color(0xFFF4FDFE);
  static const surface = Color(0xFFFFFFFF);

  // Splash gradient
  static const splashGradientStart = Color(0xFF4DD9E0);
  static const splashGradientEnd = Color(0xFF00A8B2);

  // Text
  static const textPrimary = Color(0xFF0A2A2B);
  static const textSecondary = Color(0xFF4A7A7D);

  // UI
  static const divider = Color(0xFFD8F4F5);
  static const error = Color(0xFFEF4444);
}

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        dividerColor: AppColors.divider,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      );
}
