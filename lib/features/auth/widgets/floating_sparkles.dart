import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_colors.dart';

class FloatingSparkles extends StatefulWidget {
  final bool visible;

  const FloatingSparkles({super.key, required this.visible});

  @override
  State<FloatingSparkles> createState() => _FloatingSparklesState();
}

class _FloatingSparklesState extends State<FloatingSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: widget.visible ? 1.0 : 0.8,
        duration: const Duration(milliseconds: 300),
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.05).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: Icon(
            LucideIcons.sparkles,
            size: 20,
            color: AppColors.neutral400.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
