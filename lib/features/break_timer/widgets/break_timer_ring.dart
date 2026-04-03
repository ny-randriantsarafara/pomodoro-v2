import 'package:flutter/material.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/utils/format_helpers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class BreakTimerRing extends StatelessWidget {
  final int timeLeft;
  final int initialTime;

  const BreakTimerRing({
    super.key,
    required this.timeLeft,
    required this.initialTime,
  });

  @override
  Widget build(BuildContext context) {
    final progress = initialTime > 0 ? (initialTime - timeLeft) / initialTime : 0.0;

    return ProgressRing(
      size: 256,
      strokeWidth: 4,
      progress: progress,
      activeColor: AppColors.neutral800,
      backgroundColor: AppColors.neutral200,
      child: Text(
        formatTimer(timeLeft),
        style: AppTypography.timerMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
