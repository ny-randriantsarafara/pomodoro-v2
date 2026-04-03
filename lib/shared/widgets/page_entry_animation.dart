import 'package:flutter/material.dart';
import '../../theme/app_motion.dart';

class PageEntryAnimation extends StatelessWidget {
  final Widget child;

  const PageEntryAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppMotion.pageEntryDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, AppMotion.pageEntryOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
