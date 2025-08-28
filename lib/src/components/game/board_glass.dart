import 'dart:ui';
import 'package:flutter/material.dart';

class BoardGlass extends StatelessWidget {
  final Widget child;
  final double progress; // 0..1 completion

  const BoardGlass({super.key, required this.child, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final borderOpacity = 0.18 + 0.20 * p; // stronger border
    final gradTop = (0.28 + 0.20 * p);
    final gradBottom = (0.10 + 0.12 * p);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28 + 4 * p),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28 + 4 * p),
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: 1.4,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(gradTop),
                  Colors.white.withOpacity(gradBottom),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.40 * p),
                  blurRadius: 60 + 50 * p,
                  spreadRadius: 4 * p,
                  offset: Offset(0, 20 - 4 * p),
                ),
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.35 * p),
                  blurRadius: 70 + 60 * p,
                  spreadRadius: 6 * p,
                  offset: Offset(0, 28 - 6 * p),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.08 + 0.12 * p),
                  blurRadius: 20 + 10 * p,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(padding: EdgeInsets.all(8.0 + 2 * p), child: child),
          ),
        ),
      ),
    );
  }
}
