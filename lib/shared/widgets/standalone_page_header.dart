import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class StandalonePageHeader extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconBgColor;
  final Color iconFgColor;
  final String? subtitle;
  final VoidCallback onBack;

  const StandalonePageHeader({
    super.key,
    required this.title,
    required this.iconData,
    required this.iconBgColor,
    required this.iconFgColor,
    this.subtitle,
    required this.onBack,
  });

  static const _breakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _breakpoint;
        return isDesktop ? _buildDesktop() : _buildMobile();
      },
    );
  }

  Widget _buildMobile() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: _BackButton(onBack: onBack),
          ),
          Text(
            title,
            style: AppTypography.bodyBase.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackButton(onBack: onBack),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppRadii.borderLg,
                boxShadow: AppShadows.sm,
                border: Border.all(
                  color: AppColors.surfaceBorderLight,
                ),
              ),
              child: Icon(iconData, color: iconFgColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading3xl),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onBack;

  const _BackButton({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(AppRadii.full),
        hoverColor: AppColors.neutral200.withValues(alpha: 0.5),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Icon(Icons.arrow_back, size: 20, color: AppColors.neutral900),
        ),
      ),
    );
  }
}
