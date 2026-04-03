import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_motion.dart';
import '../history_calculations.dart';
import '../../../shared/utils/format_helpers.dart';

class RhythmBarChart extends StatelessWidget {
  final List<RhythmDay> days;

  const RhythmBarChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxMins = days.fold<int>(0, (m, d) => d.totalMinutes > m ? d.totalMinutes : m);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderXxxl,
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.activity, size: 16, color: AppColors.neutral400),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Last 7 Days',
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (index) {
                final day = days[index];
                final heightPercent = maxMins > 0
                    ? (day.totalMinutes / maxMins).clamp(0.04, 1.0)
                    : 0.04;
                final dayLabel = DateFormat('E').format(day.date).substring(0, 1);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: heightPercent),
                              duration: AppMotion.barGrowDuration,
                              curve: Curves.easeOutBack,
                              builder: (context, value, _) {
                                return FractionallySizedBox(
                                  heightFactor: value,
                                  child: Tooltip(
                                    message: formatDuration(day.totalMinutes * 60),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: day.isToday
                                            ? AppColors.neutral900
                                            : day.totalMinutes > 0
                                                ? AppColors.neutral200
                                                : AppColors.neutral100,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6),
                                        ),
                                        boxShadow: day.isToday ? AppShadows.sm : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          dayLabel,
                          style: AppTypography.caption.copyWith(
                            color: day.isToday
                                ? AppColors.neutral900
                                : AppColors.neutral400,
                            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
