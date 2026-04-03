import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/page_entry_animation.dart';
import '../../shared/utils/format_helpers.dart';
import '../../store/providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import 'history_calculations.dart';
import 'widgets/rhythm_bar_chart.dart';
import 'widgets/stat_card.dart';
import 'widgets/top_focus_areas.dart';
import 'widgets/session_log.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(appStoreProvider);
    final sessions = store.sessions;
    final tasks = store.tasks;
    final projects = store.projects;

    final totalSeconds = totalFocusSeconds(sessions);
    final rhythmData = buildRhythmData(sessions);
    final topTasks = buildTopTaskStats(sessions, tasks, projects);
    final sessionGroups = groupSessionsByDayLabel(sessions);
    final activeProjects = projects.where((p) =>
      sessions.any((s) => s.projectName == p.name)).length;

    return PageEntryAnimation(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Rhythm',
              style: AppTypography.heading2xl.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            RhythmBarChart(days: rhythmData),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobileGrid = constraints.maxWidth < 500;
                final columns = isMobileGrid ? 2 : 3;
                const gap = AppSpacing.lg;
                final cardWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        icon: LucideIcons.timer,
                        label: 'Total Focus',
                        value: formatDuration(totalSeconds),
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        icon: LucideIcons.trophy,
                        label: 'Sessions',
                        value: '${sessions.length}',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: StatCard(
                        icon: LucideIcons.layers,
                        label: 'Active Projects',
                        value: '$activeProjects',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxxl),
            TopFocusAreas(stats: topTasks),
            const SizedBox(height: AppSpacing.xxxl),
            SessionLog(groups: sessionGroups),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
