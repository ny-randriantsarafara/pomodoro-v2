import 'package:flutter/painting.dart';

class AppTypography {
  AppTypography._();

  static const fontFamily = 'Inter';
  static const monoFamily = 'JetBrainsMono';

  static const heading2xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const headingXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const heading3xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodyBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodyXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const labelUppercase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static const labelUppercaseXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static const timerLarge = TextStyle(
    fontFamily: monoFamily,
    fontSize: 72,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const timerMedium = TextStyle(
    fontFamily: monoFamily,
    fontSize: 56,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
