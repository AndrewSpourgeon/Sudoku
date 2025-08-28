import 'package:flutter/material.dart';

class EntranceTransition extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;
  final double dy;
  const EntranceTransition({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.dy = 40,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double t = ((controller.value - start) / (end - start)).clamp(0, 1);
        final v = Curves.easeOutCubic.transform(t);
        final scale = 0.92 + 0.08 * v;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, dy * (1 - v)),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
