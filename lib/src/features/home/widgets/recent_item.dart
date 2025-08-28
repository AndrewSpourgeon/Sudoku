import 'package:flutter/material.dart';

class RecentItem extends StatefulWidget {
  final String title; // e.g. EASY - WIN / HARD - LOSS
  final String
  subtitle; // currently formatted as YYYY-MM-DD · Xm Ys OR just date
  final bool win;
  const RecentItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.win,
  });
  @override
  State<RecentItem> createState() => _RecentItemState();
}

class _RecentItemState extends State<RecentItem>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final accent = widget.win
        ? const Color(0xFF10F4B4)
        : const Color(0xFFFF4E70);
    // Split subtitle into date + optional time (expects "date · time")
    String date = widget.subtitle;
    String time = '';
    final parts = widget.subtitle.split(' · ');
    if (parts.isNotEmpty) {
      date = parts.first;
      if (parts.length > 1) {
        time = parts.sublist(1).join(' · '); // in case more separators
      }
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _pressed ? 0.965 : 1.0, // slightly stronger press feel
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8), // tighter vertical rhythm
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ), // reduced padding for a smaller, tighter look
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), // slightly smaller radius
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.9,
            ),
            // Softer + lighter gradient for a "cute" chip feel
            gradient: LinearGradient(
              colors: [
                accent.withOpacity(0.22),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.015),
              ],
              stops: const [0.0, 0.55, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.40),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status icon badge (smaller & lighter)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.92),
                      accent.withOpacity(0.50),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.win ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title (smaller, playful weight)
                    ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        colors: [Colors.white, accent.withOpacity(0.80)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(rect),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 10),
                // Time pill (reduced size)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.90),
                        accent.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.60),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
