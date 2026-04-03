import 'package:flutter/material.dart';

class AnimatedPresence extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Widget Function(Widget child, Animation<double> animation)? transitionBuilder;

  const AnimatedPresence({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: transitionBuilder ??
          (child, animation) => FadeTransition(opacity: animation, child: child),
      child: visible ? child : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }
}
