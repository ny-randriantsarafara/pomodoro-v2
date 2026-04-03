import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class TaskComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onProjectTap;
  final String? selectedProjectName;
  final ProjectStyle? selectedProjectStyle;
  final bool showProjectRow;
  final bool showAddButton;

  const TaskComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onProjectTap,
    this.selectedProjectName,
    this.selectedProjectStyle,
    required this.showProjectRow,
    required this.showAddButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.borderXxl,
            border: Border.all(color: AppColors.neutral200),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSubmit(),
                  style: AppTypography.bodyBase.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'What do you want to focus on?',
                    hintStyle: AppTypography.bodyBase.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: showAddButton
                    ? GestureDetector(
                        key: const ValueKey('add'),
                        onTap: onSubmit,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.neutral900,
                              borderRadius: AppRadii.borderLg,
                            ),
                            child: const Icon(LucideIcons.plus, size: 18, color: AppColors.white),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 225),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 225),
              opacity: showProjectRow ? 1.0 : 0.0,
              child: showProjectRow
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm, left: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: onProjectTap,
                        child: Row(
                          children: [
                            if (selectedProjectName != null && selectedProjectStyle != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: selectedProjectStyle!.background,
                                  borderRadius: AppRadii.borderSm,
                                ),
                                child: Text(
                                  selectedProjectName!,
                                  style: AppTypography.bodyXs.copyWith(
                                    color: selectedProjectStyle!.foreground,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Add project',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
