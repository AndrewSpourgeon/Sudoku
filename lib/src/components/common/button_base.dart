import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final BoxDecoration? decoration;

  const ButtonBase({
    super.key,
    required this.child,
    required this.onTap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: const BoxConstraints(minHeight: 48),
        decoration:
            decoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
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
                  color: Colors.white.withOpacity(0.07),
                  blurRadius: 14,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
        child: child,
      ),
    );
  }
}
