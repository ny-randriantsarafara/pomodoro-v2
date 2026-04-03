import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.56;
    final radius = size * 0.3125;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(iconSize, iconSize),
          painter: _ClockIconPainter(),
        ),
      ),
    );
  }
}

class _ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius * 0.83, paint);

    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.5),
      center,
      paint,
    );

    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.33, center.dy + radius * 0.17),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
