import 'package:flutter/material.dart';
import 'button_base.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final BoxDecoration? customDecoration;

  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.customDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonBase(
      onTap: onTap,
      decoration: customDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
