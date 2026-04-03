import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        primary: AppColors.neutral900,
        onPrimary: AppColors.white,
        outline: AppColors.surfaceBorder,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.neutral200,
        cursorColor: AppColors.neutral900,
      ),
    );
  }
}
