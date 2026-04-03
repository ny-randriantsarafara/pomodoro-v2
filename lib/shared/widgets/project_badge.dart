import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class ProjectBadge extends StatelessWidget {
  final String name;
  final ProjectStyle style;
  final bool small;

  const ProjectBadge({
    super.key,
    required this.name,
    required this.style,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: AppRadii.borderSm,
      ),
      child: Text(
        name,
        style: (small ? AppTypography.labelUppercaseXs : AppTypography.bodyXs)
            .copyWith(color: style.foreground),
      ),
    );
  }
}
