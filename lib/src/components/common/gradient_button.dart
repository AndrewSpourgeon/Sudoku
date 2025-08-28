import 'package:flutter/material.dart';
import 'button_base.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color1;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color1,
  });

  @override
  Widget build(BuildContext context) {
    final c1 = color1 ?? const Color(0xFF06B6D4);
    final c2 = const Color(0xFF6366F1);
    return ButtonBase(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [c1.withOpacity(0.95), c2.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: c1.withOpacity(0.70),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 14,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
      ),
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13.5,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
