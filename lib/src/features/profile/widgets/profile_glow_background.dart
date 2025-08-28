import 'package:flutter/material.dart';

class ProfileGlowBackground extends StatelessWidget {
  const ProfileGlowBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _ProfileGlowPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _ProfileGlowPainter extends CustomPainter {
  const _ProfileGlowPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 180);
    paint.color = const Color(0xFF06B6D4).withOpacity(0.28);
    canvas.drawCircle(center.translate(-40, -160), size.width * 0.55, paint);
    paint.color = const Color(0xFF6366F1).withOpacity(0.25);
    canvas.drawCircle(center.translate(120, -40), size.width * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
