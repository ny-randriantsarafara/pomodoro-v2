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

    Future.delayed(AppMotion.blobBDelay, () {
      if (mounted) _blobBController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _blobAController.dispose();
    _blobBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: AnimatedBuilder(
            animation: _blobAController,
            builder: (context, _) {
              final scale = 1.0 + 0.1 * _blobAController.value;
              final opacity = 0.3 + 0.1 * _blobAController.value;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                    child: Container(
                      width: 600,
                      height: 600,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF818CF8),
                            Color(0x00818CF8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: AnimatedBuilder(
            animation: _blobBController,
            builder: (context, _) {
              final scale = 1.0 + 0.2 * _blobBController.value;
              final opacity = 0.2 + 0.1 * _blobBController.value;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFA78BFA),
                            Color(0x00A78BFA),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
