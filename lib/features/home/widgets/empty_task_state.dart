import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class EmptyTaskState extends StatelessWidget {
  const EmptyTaskState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.huge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.listTodo, size: 32, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.md),
          Text('No tasks yet.', style: AppTypography.bodyBase.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.xs),
          Text('Add a task above to get started.', style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
