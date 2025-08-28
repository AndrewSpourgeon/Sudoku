import 'dart:math' as math;
import 'package:flutter/material.dart';

class LeaderboardParticles extends StatelessWidget {
  final Animation<double> animation;
  const LeaderboardParticles({super.key, required this.animation});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final size = MediaQuery.of(context).size;
          final rnd = math.Random(42); // deterministic layout
          final dots = <Widget>[];
          final t = animation.value;
          for (int i = 0; i < 26; i++) {
            final baseX = rnd.nextDouble();
            final baseY = rnd.nextDouble();
            final driftX = math.sin((t * 2 * math.pi) + i) * 0.015;
            final driftY = math.cos((t * 2 * math.pi) + i * .6) * 0.02;
            final dx = (baseX + driftX).clamp(0.0, 1.0);
            final dy = (baseY + driftY).clamp(0.0, 1.0);
            final pulse =
                0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 * math.pi + i));
            final sz = 4.0 + 8.0 * pulse;
            final hueShift = (i / 26.0);
            final color = HSVColor.fromAHSV(
              0.55,
              (200 + 140 * hueShift) % 360,
              0.55,
              1.0,
            ).toColor();
            dots.add(
              Positioned(
                left: dx * size.width - sz / 2,
                top: dy * size.height - sz / 2,
                child: Container(
                  width: sz,
                  height: sz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.75),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(.55),
                        blurRadius: 12 * pulse,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Stack(children: dots);
        },
      ),
    );
  }
}
