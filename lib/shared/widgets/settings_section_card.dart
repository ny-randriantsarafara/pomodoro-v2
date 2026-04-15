import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';

class SettingsSectionCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDesktop;

  const SettingsSectionCard({
    super.key,
    required this.children,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isDesktop ? AppRadii.borderXxl : AppRadii.borderXl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.8),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _insertDividers(children),
        ),
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> items) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Divider(height: 1, color: AppColors.surfaceBorderLight),
        );
      }
    }
    return result;
  }
}
