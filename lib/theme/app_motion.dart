import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  static const smoothCurve = Cubic(0.16, 1, 0.3, 1);
  static const focusIntroCurve = Cubic(0.2, 0.9, 0.4, 1);
  static const standard = Curves.easeOut;
  static const decelerate = Curves.easeOutCubic;

  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const slower = Duration(milliseconds: 800);

  static const introTitleDuration = Duration(milliseconds: 1200);
  static const introTimerDelay = Duration(milliseconds: 1200);
  static const introTimerDuration = Duration(milliseconds: 1500);
  static const introControlsDelay = Duration(milliseconds: 2000);
  static const introControlsDuration = Duration(milliseconds: 1000);
  static const introProjectBadgeDelay = Duration(milliseconds: 800);
  static const introProjectBadgeDuration = Duration(milliseconds: 1000);
  static const atmospheric = Duration(seconds: 3);

  static const introPhaseDelay = Duration(milliseconds: 2500);
  static const celebrationDelay = Duration(milliseconds: 3500);
  static const postCreateAutoHide = Duration(seconds: 4);

  static const pageEntryDuration = Duration(milliseconds: 500);
  static const pageEntryOffset = 16.0;

  static const barGrowDuration = Duration(milliseconds: 800);
  static const barStaggerDelay = Duration(milliseconds: 100);

  static const blobADuration = Duration(seconds: 8);
  static const blobBDuration = Duration(seconds: 10);
  static const blobBDelay = Duration(seconds: 1);
  static const authContainerDuration = Duration(milliseconds: 500);
  static const authStaggerInterval = Duration(milliseconds: 100);
  static const shimmerDuration = Duration(milliseconds: 1500);
}
