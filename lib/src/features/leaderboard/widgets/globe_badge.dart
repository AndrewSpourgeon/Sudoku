import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlobeBadge extends StatefulWidget {
  const GlobeBadge({super.key});
  @override
  State<GlobeBadge> createState() => _GlobeBadgeState();
}

class _GlobeBadgeState extends State<GlobeBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final pulse = 0.94 + 0.06 * math.sin(t * 2 * math.pi);
        final ringRotate = t * 2 * math.pi;
        final iconRotate = t * math.pi;
        final glowStrength = 0.45 + 0.1 * math.sin(t * 2 * math.pi);
        final orbitAngle = ringRotate * 0.8;
        const orbitRadius = 16.0;
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF6366F1,
                  ).withOpacity(glowStrength.clamp(0, .9)),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(.38),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: ringRotate,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(.30),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0.15, 0.5, 0.85],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    orbitRadius * math.cos(orbitAngle),
                    orbitRadius * math.sin(orbitAngle),
                  ),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF9C4), Color(0xFFFFD700)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(3.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(.25),
                      width: 1,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: iconRotate,
                  child: const Icon(
                    Icons.public_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
