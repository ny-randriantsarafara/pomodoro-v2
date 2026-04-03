import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/project_badge.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import 'phase_label.dart';

class FocusTitleBlock extends StatelessWidget {
  final String title;
  final Project? project;
  final bool showPhaseLabel;
  final String phaseText;
  final Animation<double> animation;

  const FocusTitleBlock({
    super.key,
    required this.title,
    this.project,
    required this.showPhaseLabel,
    required this.phaseText,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.heading3xl.copyWith(
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (project != null) ...[
              const SizedBox(height: AppSpacing.md),
              ProjectBadge(
                name: project!.name,
                style: project!.style,
                small: true,
              ),
            ],
            if (showPhaseLabel) ...[
              const SizedBox(height: AppSpacing.xl),
              PhaseLabel(text: phaseText),
            ],
          ],
        ),
      ),
    );
  }
}
