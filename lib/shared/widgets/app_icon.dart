import 'package:flutter/material.dart';

class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.3125;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
