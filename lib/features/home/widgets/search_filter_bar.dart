import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String activeProjectId;
  final List<Project> projects;
  final ValueChanged<String> onProjectChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.activeProjectId,
    required this.projects,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.borderXl,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.md),
                child: Icon(LucideIcons.search, size: 16, color: AppColors.neutral400),
              ),
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('All', 'all'),
              ...projects.map((p) => _chip(p.name, p.id)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String id) {
    final isActive = activeProjectId == id;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => onProjectChanged(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.neutral900 : AppColors.surface,
            borderRadius: AppRadii.borderFull,
            border: Border.all(color: isActive ? AppColors.neutral900 : AppColors.neutral200),
          ),
          child: Text(
            label,
            style: AppTypography.bodyXs.copyWith(
              color: isActive ? AppColors.white : AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
