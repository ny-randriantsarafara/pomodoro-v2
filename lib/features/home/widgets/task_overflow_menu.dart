import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class TaskOverflowMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskOverflowMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuRow(
            icon: LucideIcons.pencil,
            label: 'Edit task',
            foreground: AppColors.textPrimary,
            onTap: onEdit,
          ),
          const SizedBox(height: AppSpacing.xs),
          _MenuRow(
            icon: LucideIcons.trash2,
            label: 'Delete',
            foreground: AppColors.destructive,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(borderRadius: AppRadii.borderSm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
