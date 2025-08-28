import 'dart:ui';
import 'package:flutter/material.dart';

class GlassShell extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;
  final BorderRadius? borderRadius;

  const GlassShell({
    super.key,
    required this.padding,
    required this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                ), // brighter
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.30),
                    Colors.white.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.65),
                    blurRadius: 55,
                    offset: const Offset(0, 34),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.06),
                    blurRadius: 18,
                    spreadRadius: -6,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
