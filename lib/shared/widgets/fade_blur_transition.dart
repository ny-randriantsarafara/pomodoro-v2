import 'dart:ui';
import 'package:flutter/material.dart';

class FadeBlurTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double maxBlur;

  const FadeBlurTransition({
    super.key,
    required this.animation,
    required this.child,
    this.maxBlur = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final blur = (1 - animation.value) * maxBlur;
        return Opacity(
          opacity: animation.value,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: child,
          ),
        );
      },
    );
  }
}
