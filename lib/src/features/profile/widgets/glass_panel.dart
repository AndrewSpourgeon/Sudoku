import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final List<Color>? accent;
  final bool iconOnRight; // existing param
  final Widget? headerAction; // new optional action widget (e.g., info icon)
  const GlassPanel({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accent,
    this.iconOnRight = false,
    this.headerAction,
  });
  @override
  Widget build(BuildContext context) {
    final grad =
        accent ??
        [Colors.white.withOpacity(0.16), Colors.white.withOpacity(0.05)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: grad.length == 2
                  ? [grad[0].withOpacity(0.32), grad[1].withOpacity(0.10)]
                  : [
                      Colors.white.withOpacity(0.28),
                      Colors.white.withOpacity(0.08),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.18),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(-6, -6),
              ),
              BoxShadow(
                color: (accent != null ? accent!.last : const Color(0xFF6366F1))
                    .withOpacity(0.28),
                blurRadius: 48,
                spreadRadius: 6,
                offset: const Offset(0, 30),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 44,
                offset: const Offset(0, 32),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null && !iconOnRight)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [grad.first, grad.last],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: grad.last.withOpacity(.55),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                  if (icon != null && !iconOnRight) const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (headerAction != null) headerAction!,
                  if (icon != null && iconOnRight) const SizedBox(width: 14),
                  if (icon != null && iconOnRight)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [grad.first, grad.last],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: grad.last.withOpacity(.55),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
