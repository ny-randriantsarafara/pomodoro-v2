import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class TaskOverflowMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const TaskOverflowMenu({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderLg,
        boxShadow: AppShadows.lg,
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(borderRadius: AppRadii.borderSm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.trash2, size: 14, color: AppColors.destructive),
              const SizedBox(width: AppSpacing.sm),
              Text('Delete', style: AppTypography.bodySm.copyWith(color: AppColors.destructive)),
            ],
          ),
        ),
      ),
    );
  }
}
