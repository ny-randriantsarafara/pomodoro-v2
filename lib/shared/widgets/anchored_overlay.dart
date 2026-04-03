import 'package:flutter/material.dart';

class AnchoredOverlayController {
  OverlayEntry? _entry;
  bool get isOpen => _entry != null;

  void show({required OverlayEntry entry}) {
    close();
    _entry = entry;
  }

  void close() {
    _entry?.remove();
    _entry = null;
  }
}

class AnchoredOverlayTarget extends StatelessWidget {
  final LayerLink link;
  final Widget child;

  const AnchoredOverlayTarget({
    super.key,
    required this.link,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: link, child: child);
  }
}

class AnchoredOverlayFollower extends StatelessWidget {
  final LayerLink link;
  final Offset offset;
  final Widget child;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  const AnchoredOverlayFollower({
    super.key,
    required this.link,
    required this.offset,
    required this.child,
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: offset,
      child: child,
    );
  }
}

OverlayEntry buildAnchoredOverlay({
  required BuildContext context,
  required LayerLink link,
  required Widget child,
  required VoidCallback onDismiss,
  Offset offset = const Offset(0, 8),
  Alignment targetAnchor = Alignment.bottomLeft,
  Alignment followerAnchor = Alignment.topLeft,
}) {
  return OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        AnchoredOverlayFollower(
          link: link,
          offset: offset,
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ],
    ),
  );
}
