import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/press_scale_button.dart';
import '../../../shared/widgets/hover_scale_icon.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class FocusControls extends StatelessWidget {
  final bool isActive;
  final bool disabled;
  final VoidCallback onPrimary;
  final VoidCallback onAbandon;
  final VoidCallback onSaveEnd;
  final Animation<double> animation;

  const FocusControls({
    super.key,
    required this.isActive,
    required this.disabled,
    required this.onPrimary,
    required this.onAbandon,
    required this.onSaveEnd,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 64,
              child: PressScaleButton(
                scaleDown: 0.98,
                onPressed: disabled ? null : onPrimary,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.white : AppColors.focusSurface,
                    borderRadius: AppRadii.borderXxl,
                    border: Border.all(
                      color: isActive ? Colors.transparent : AppColors.focusBorder,
                    ),
                    boxShadow: AppShadows.focusButton,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      key: ValueKey(isActive),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? LucideIcons.pause : LucideIcons.play,
                          size: 20,
                          color: isActive ? AppColors.neutral900 : AppColors.white,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          isActive ? 'Pause' : 'Resume',
                          style: AppTypography.bodyBase.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.neutral900 : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HoverScaleIcon(
                  onTap: disabled ? null : onAbandon,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.x, size: 16, color: AppColors.neutral500),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Abandon',
                          style: AppTypography.bodySm.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxl),
                HoverScaleIcon(
                  onTap: disabled ? null : onSaveEnd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.square, size: 16, color: AppColors.neutral500),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Save & End',
                          style: AppTypography.bodySm.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
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
