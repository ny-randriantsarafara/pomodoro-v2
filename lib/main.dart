import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import 'theme/app_spacing.dart';
import 'theme/app_radii.dart';
import 'theme/app_shadows.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';

void main() {
  debugPrint('Colors bg: ${AppColors.background}');
  debugPrint('Spacing lg: ${AppSpacing.lg}');
  debugPrint('Radii md: ${AppRadii.md}');
  debugPrint('Shadows: ${AppShadows.sm}');
  debugPrint('Motion: ${AppMotion.slow}');
  debugPrint('Typography: ${AppTypography.fontFamily}');
  runApp(MaterialApp(theme: AppTheme.light, home: const SizedBox()));
}
