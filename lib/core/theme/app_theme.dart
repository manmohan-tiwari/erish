import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// ERISH Official Design System - Global Theme Specification
class AppTheme {
  // Re-export core colors for convenient static access
  static const Color ivory = AppColors.warmIvory;
  static const Color cream = AppColors.cream;
  static const Color ink = AppColors.espresso;
  static const Color emerald = AppColors.emerald;
  static const Color pink = AppColors.emerald;
  static const Color pinkSoft = AppColors.emeraldLight;
  static const Color gold = AppColors.gold;
  static const Color terracotta = AppColors.gold;
  static const Color softOlive = AppColors.softOlive;
  static const Color sandBorder = AppColors.sandBorder;
  static const Color mutedText = AppColors.muted;
  static const Color lightMuted = AppColors.lightMuted;

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.warmIvory,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.emerald,
        onPrimary: AppColors.warmIvory,
        secondary: AppColors.gold,
        onSecondary: Colors.white,
        tertiary: AppColors.softOlive,
        onTertiary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: AppColors.warmIvory,
        onSurface: AppColors.espresso,
        outline: AppColors.sandBorder,
        outlineVariant: AppColors.lightMuted,
        surfaceContainerHighest: AppColors.paperWhite,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayHero(),
        headlineMedium: AppTypography.sectionTitle(),
        titleMedium: AppTypography.cardTitle(),
        bodyLarge: AppTypography.body(),
        labelLarge: AppTypography.button(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.sandBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );

    return base;
  }
}
