import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../theme/app_motion.dart';

class AuthBackgroundBlobs extends StatefulWidget {
  const AuthBackgroundBlobs({super.key});

  @override
  State<AuthBackgroundBlobs> createState() => _AuthBackgroundBlobsState();
}

class _AuthBackgroundBlobsState extends State<AuthBackgroundBlobs>
    with TickerProviderStateMixin {
  late final AnimationController _blobAController;
  late final AnimationController _blobBController;
  late final AnimationController _blobCController;

  @override
  void initState() {
    super.initState();
    _blobAController = AnimationController(
      vsync: this,
      duration: AppMotion.blobADuration,
    )..repeat(reverse: true);

    _blobBController = AnimationController(
      vsync: this,
      duration: AppMotion.blobBDuration,
    );

    _blobCController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    Future<void>.delayed(AppMotion.blobBDelay, () {
      if (mounted) _blobBController.repeat(reverse: true);
    });
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _blobCController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _blobAController.dispose();
    _blobBController.dispose();
    _blobCController.dispose();
    super.dispose();
  }

  static Widget _blurredOrb({
    required double size,
    required List<Color> colors,
    required double sigma,
    required double scale,
    required double opacity,
  }) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Upper-center glow: reads above the form on mobile.
            Positioned(
              top: h * 0.04,
              left: w * 0.5 - 175,
              child: AnimatedBuilder(
                animation: _blobCController,
                builder: (context, _) {
                  final t = _blobCController.value;
                  final scale = 1.0 + 0.12 * t;
                  final opacity = 0.52 + 0.14 * t;
                  return _blurredOrb(
                    size: 350,
                    colors: const [
                      Color(0xFF93C5FD),
                      Color(0x4093C5FD),
                      Color(0x0093C5FD),
                    ],
                    sigma: 56,
                    scale: scale,
                    opacity: opacity,
                  );
                },
              ),
            ),
            // Indigo drift — upper left.
            Positioned(
              top: -h * 0.06,
              left: -w * 0.15,
              child: AnimatedBuilder(
                animation: _blobAController,
                builder: (context, _) {
                  final scale = 1.0 + 0.1 * _blobAController.value;
                  final opacity = 0.48 + 0.12 * _blobAController.value;
                  return _blurredOrb(
                    size: 620,
                    colors: const [
                      Color(0xFF818CF8),
                      Color(0x00818CF8),
                    ],
                    sigma: 52,
                    scale: scale,
                    opacity: opacity,
                  );
                },
              ),
            ),
            // Violet bloom — lower right.
            Positioned(
              bottom: -h * 0.04,
              right: -w * 0.12,
              child: AnimatedBuilder(
                animation: _blobBController,
                builder: (context, _) {
                  final scale = 1.0 + 0.18 * _blobBController.value;
                  final opacity = 0.4 + 0.14 * _blobBController.value;
                  return _blurredOrb(
                    size: 440,
                    colors: const [
                      Color(0xFFC4B5FD),
                      Color(0x00C4B5FD),
                    ],
                    sigma: 50,
                    scale: scale,
                    opacity: opacity,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
