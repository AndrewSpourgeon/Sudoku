import 'package:flutter/material.dart';

class NebulaBackground extends StatelessWidget {
  final Animation<double> animation;
  const NebulaBackground({super.key, required this.animation});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => CustomPaint(
        painter: _NebulaPainter(progress: animation.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  final double progress;
  _NebulaPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .3);
    final p = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 180);

    p.color = const Color(0xFF6366F1).withOpacity(.32);
    canvas.drawCircle(
      center.translate(140 * (progress - .5), 80 * (progress - .5)),
      340,
      p,
    );

    p.color = const Color(0xFF06B6D4).withOpacity(.30);
    canvas.drawCircle(
      center.translate(-160 * (progress - .5), -40 * (progress - .5)),
      300,
      p,
    );

    p.color = const Color(0xFFF472B6).withOpacity(.26);
    canvas.drawCircle(
      center.translate(40 * (progress - .5), -120 * (progress - .5)),
      260,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) => true;
}
