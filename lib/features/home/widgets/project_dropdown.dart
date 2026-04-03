import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class ProjectDropdown extends StatelessWidget {
  final List<Project> projects;
  final bool isAddingProject;
  final String newProjectName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onStartCreate;
  final VoidCallback onCancelCreate;
  final void Function(String? projectId) onSelectProject;
  final VoidCallback onCommitCreate;

  const ProjectDropdown({
    super.key,
    required this.projects,
    required this.isAddingProject,
    required this.newProjectName,
    required this.onNameChanged,
    required this.onStartCreate,
    required this.onCancelCreate,
    required this.onSelectProject,
    required this.onCommitCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.borderXl,
        boxShadow: AppShadows.xl,
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _item('No Project', null),
          ...projects.map((p) => _item(p.name, p.id, style: p.style)),
          const Divider(height: 1, color: AppColors.surfaceBorderLight),
          if (isAddingProject) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: onNameChanged,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Project name...',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                      border: OutlineInputBorder(borderRadius: AppRadii.borderSm, borderSide: BorderSide(color: AppColors.neutral200)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onCancelCreate,
                        child: Text('Cancel', style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: newProjectName.trim().isNotEmpty ? onCommitCreate : null,
                        child: Text('Add Project', style: AppTypography.bodySm.copyWith(
                          color: newProjectName.trim().isNotEmpty ? AppColors.neutral900 : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else
            GestureDetector(
              onTap: onStartCreate,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Create new project',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _item(String name, String? id, {ProjectStyle? style}) {
    return GestureDetector(
      onTap: () => onSelectProject(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            if (style != null)
              Container(
                width: 8, height: 8, margin: const EdgeInsets.only(right: AppSpacing.sm),
                decoration: BoxDecoration(color: style.foreground, shape: BoxShape.circle),
              ),
            Text(name, style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
