import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class TodayHeader extends StatelessWidget {
  final String summary;
  const TodayHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today', style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.xs),
        Text(summary, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
