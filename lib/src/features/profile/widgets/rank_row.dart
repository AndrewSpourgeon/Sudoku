import 'package:flutter/material.dart';

class RankRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  const RankRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c.withOpacity(0.95), c.withOpacity(0.55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.withOpacity(.55),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.45),
                  width: 1.1,
                ),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
