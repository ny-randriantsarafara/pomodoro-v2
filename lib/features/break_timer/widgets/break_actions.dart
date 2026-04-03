import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/press_scale_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class BreakActions extends StatelessWidget {
  final Task? task;
  final bool hasContinuePrimary;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const BreakActions({
    super.key,
    this.task,
    required this.hasContinuePrimary,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasContinuePrimary && task != null) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: PressScaleButton(
              scaleDown: 0.98,
              onPressed: onContinue,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.neutral900,
                  borderRadius: AppRadii.borderXxl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play, size: 18, color: AppColors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'Continue ${task!.title}',
                        style: AppTypography.bodyBase.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        GestureDetector(
          onTap: onBack,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.neutral500),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Back to tasks',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
