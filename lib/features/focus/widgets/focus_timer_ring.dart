import 'package:flutter/material.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/utils/format_helpers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class FocusTimerRing extends StatelessWidget {
  final int timeLeft;
  final int initialTime;
  final bool showProgress;

  const FocusTimerRing({
    super.key,
    required this.timeLeft,
    required this.initialTime,
    required this.showProgress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = initialTime > 0 ? (initialTime - timeLeft) / initialTime : 0.0;
    final isFinalMinute = timeLeft < 60 && timeLeft > 0;
    final activeColor = isFinalMinute ? AppColors.focusAmber : AppColors.white;
    final textColor = isFinalMinute ? AppColors.focusAmber : AppColors.white;
    final fontWeight = isFinalMinute ? FontWeight.w500 : FontWeight.w300;

    return ProgressRing(
      size: 288,
      strokeWidth: 3,
      progress: showProgress ? progress : 0,
      activeColor: activeColor,
      backgroundColor: AppColors.neutral900,
      child: Text(
        formatTimer(timeLeft),
        style: AppTypography.timerLarge.copyWith(
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
