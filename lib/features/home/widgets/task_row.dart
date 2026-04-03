import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/project_badge.dart';
import '../../../shared/widgets/press_scale_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class TaskRow extends StatelessWidget {
  final Task task;
  final Project? project;
  final int lastUsedPreset;
  final VoidCallback onToggle;
  final VoidCallback onStart;
  final VoidCallback onPresetTap;
  final VoidCallback onMenuTap;

  const TaskRow({
    super.key,
    required this.task,
    this.project,
    required this.lastUsedPreset,
    required this.onToggle,
    required this.onStart,
    required this.onPresetTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScaleButton(
      scaleDown: task.completed ? 1.0 : 0.99,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: task.completed ? AppColors.neutral50 : AppColors.surface,
          borderRadius: AppRadii.borderXxl,
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: task.completed ? null : AppShadows.sm,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: task.completed ? 0.6 : 1.0,
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: task.completed ? AppColors.neutral900 : Colors.transparent,
                    borderRadius: AppRadii.borderSm,
                    border: Border.all(
                      color: task.completed ? AppColors.neutral900 : AppColors.neutral300,
                      width: 2,
                    ),
                  ),
                  child: task.completed
                      ? const Icon(LucideIcons.check, size: 14, color: AppColors.white)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.bodyBase.copyWith(
                        color: AppColors.textPrimary,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      ProjectBadge(name: project!.name, style: project!.style, small: true),
                    ],
                  ],
                ),
              ),
              if (!task.completed) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadii.borderXl,
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onStart,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                          child: Text(
                            'Start',
                            style: AppTypography.bodyXs.copyWith(color: AppColors.neutral600, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 20, color: AppColors.neutral200),
                      GestureDetector(
                        onTap: onPresetTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: Icon(LucideIcons.chevronDown, size: 14, color: AppColors.neutral500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: onMenuTap,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(LucideIcons.moreHorizontal, size: 18, color: AppColors.neutral400),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
