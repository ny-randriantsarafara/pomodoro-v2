import 'package:flutter/material.dart';
import '../../../shared/widgets/project_badge.dart';
import '../../../shared/utils/format_helpers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../history_calculations.dart';

class TopFocusAreas extends StatelessWidget {
  final List<TaskStat> stats;

  const TopFocusAreas({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Focus Areas',
          style: AppTypography.headingLg.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.borderXxl,
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: List.generate(stats.length, (index) {
              final stat = stats[index];
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, color: AppColors.surfaceBorderLight),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.title,
                                style: AppTypography.bodyBase.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (stat.projectName != null && stat.projectStyle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: ProjectBadge(
                                    name: stat.projectName!,
                                    style: stat.projectStyle!,
                                    small: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${stat.sessionCount} sessions',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              formatDuration(stat.totalSeconds),
                              style: AppTypography.bodyXs.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
