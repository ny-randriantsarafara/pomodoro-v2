import 'package:flutter/painting.dart';

class AppShadows {
  AppShadows._();

  static const sm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const xl = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static const focusButton = [
    BoxShadow(
      color: Color(0x0DFFFFFF),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
