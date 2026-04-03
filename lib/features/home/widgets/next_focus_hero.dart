import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/press_scale_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class NextFocusHero extends StatelessWidget {
  final String title;
  final int lastUsedPreset;
  final VoidCallback onStart;
  final VoidCallback onPresetTap;

  const NextFocusHero({
    super.key,
    required this.title,
    required this.lastUsedPreset,
    required this.onStart,
    required this.onPresetTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: AppRadii.borderXxxl,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT FOCUS',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.neutral400,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTypography.headingLg.copyWith(color: AppColors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Row(
              children: [
                PressScaleButton(
                  scaleDown: 0.95,
                  onPressed: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.borderXl,
                    ),
                    child: Text(
                      'Start $lastUsedPreset min',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onPresetTap,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.neutral800,
                      borderRadius: AppRadii.borderLg,
                    ),
                    child: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
