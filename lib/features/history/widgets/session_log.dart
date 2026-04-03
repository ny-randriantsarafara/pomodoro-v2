import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/project_badge.dart';
import '../../../shared/utils/format_helpers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../history_calculations.dart';

class SessionLog extends StatelessWidget {
  final List<SessionGroup> groups;

  const SessionLog({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.huge),
        decoration: BoxDecoration(
          borderRadius: AppRadii.borderXxl,
          border: Border.all(
            color: AppColors.neutral200,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.clock, size: 32, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No sessions yet',
              style: AppTypography.bodyBase.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Log',
          style: AppTypography.headingLg.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...groups.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    group.label.toUpperCase(),
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.borderXxl,
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    children: List.generate(group.sessions.length, (index) {
                      final session = group.sessions[index];
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
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              session.taskTitle,
                                              style: AppTypography.bodyBase.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (session.projectName != null &&
                                              session.projectStyle != null) ...[
                                            const SizedBox(width: AppSpacing.sm),
                                            ProjectBadge(
                                              name: session.projectName!,
                                              style: session.projectStyle!,
                                              small: true,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatDuration(session.duration),
                                      style: AppTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      formatTimeOfDay(session.completedAt),
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
            ),
          );
        }),
      ],
    );
  }
}
