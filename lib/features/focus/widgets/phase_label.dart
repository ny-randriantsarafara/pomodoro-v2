import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class PhaseLabel extends StatelessWidget {
  final String text;

  const PhaseLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: AppTypography.labelUppercase.copyWith(
          color: AppColors.neutral500,
          letterSpacing: 3,
        ),
      ),
    );
  }
}
