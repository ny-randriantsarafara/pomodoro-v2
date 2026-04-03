import 'package:flutter/material.dart';

class HoverScaleIcon extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverScaleIcon({
    super.key,
    required this.child,
    this.hoverScale = 1.10,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
  });

  @override
  State<HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<HoverScaleIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? widget.hoverScale : 1,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
