import 'package:flutter/material.dart';

class FillViewportScrollView extends StatelessWidget {
  const FillViewportScrollView({
    super.key,
    required this.child,
    this.physics,
  });

  final Widget child;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            child: child,
          ),
        ),
      ],
    );
  }
}
