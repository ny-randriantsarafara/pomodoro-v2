import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_motion.dart';

class FocusBackground extends StatelessWidget {
  final double progress;
  final int timeLeft;

  const FocusBackground({
    super.key,
    required this.progress,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    Alignment center;
    List<Color> colors;

    if (progress < 0.1) {
      center = const Alignment(0, -1);
      colors = [
        const Color(0xFF1e293b).withValues(alpha: 0.3),
        AppColors.focusBg,
      ];
    } else if (timeLeft < 60) {
      center = const Alignment(0, 1);
      colors = [
        const Color(0xFF4338CA).withValues(alpha: 0.15),
        AppColors.focusBg,
      ];
    } else {
      center = Alignment.center;
      colors = [
        AppColors.focusBg,
        AppColors.focusBg,
      ];
    }

    return Positioned.fill(
      child: AnimatedContainer(
        duration: AppMotion.atmospheric,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: 1.2,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
