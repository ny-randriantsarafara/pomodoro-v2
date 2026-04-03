import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'break_timer_ring.dart';

class RecoveryState extends StatelessWidget {
  final Task? task;
  final int timeLeft;
  final int initialTime;
  final Widget actions;

  const RecoveryState({
    super.key,
    this.task,
    required this.timeLeft,
    required this.initialTime,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + 0.05 * value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.coffee, size: 24, color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Recovery',
            style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
          ),
          if (task != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Resting after: ${task!.title}',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          BreakTimerRing(timeLeft: timeLeft, initialTime: initialTime),
          const SizedBox(height: AppSpacing.xxxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: actions,
          ),
        ],
      ),
    );
  }
}
