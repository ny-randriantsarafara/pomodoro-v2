import 'package:flutter/material.dart';
import '../../../shared/widgets/press_scale_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class PostCreateAffordance extends StatelessWidget {
  final String title;
  final int lastUsedPreset;
  final VoidCallback onDismiss;
  final VoidCallback onStart;

  const PostCreateAffordance({
    super.key,
    required this.title,
    required this.lastUsedPreset,
    required this.onDismiss,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -10 * (1 - value)),
            child: Transform.scale(scale: 0.95 + 0.05 * value, child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.borderXl,
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: AppShadows.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '"$title" added',
                style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onDismiss,
              child: Text('Dismiss', style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
            ),
            const SizedBox(width: AppSpacing.sm),
            PressScaleButton(
              scaleDown: 0.95,
              onPressed: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neutral900,
                  borderRadius: AppRadii.borderLg,
                ),
                child: Text(
                  'Start $lastUsedPreset min',
                  style: AppTypography.bodyXs.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
