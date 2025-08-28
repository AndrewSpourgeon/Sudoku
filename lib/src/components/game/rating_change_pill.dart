import 'package:flutter/material.dart';

class RatingChangePill extends StatelessWidget {
  final int oldRating;
  final int newRating;
  final int delta;
  final bool isWin;

  const RatingChangePill({
    super.key,
    required this.oldRating,
    required this.newRating,
    required this.delta,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    final gained = delta > 0;
    final neutral = delta == 0;
    final baseColors = neutral
        ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
        : gained
        ? [const Color(0xFF10B981), const Color(0xFF059669)]
        : [const Color(0xFFF87171), const Color(0xFFDC2626)];
    final icon = neutral
        ? Icons.horizontal_rule_rounded
        : gained
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final iconBg = gained
        ? const Color(0xFF047857)
        : (neutral ? const Color(0xFF334155) : const Color(0xFF7F1D1D));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: baseColors.map((c) => c.withOpacity(0.95)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColors.last.withOpacity(.70),
            blurRadius: 38,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.10),
            blurRadius: 18,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.28), width: 1.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [iconBg.withOpacity(.95), iconBg.withOpacity(.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconBg.withOpacity(.65),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(.25)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gained
                    ? (isWin ? 'RATING GAIN' : 'RATING CHANGE')
                    : (neutral
                          ? 'RATING'
                          : (isWin ? 'UNUSUAL' : 'RATING LOSS')),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(.85),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ratingNumber(oldRating, context),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(.85),
                  ),
                  const SizedBox(width: 6),
                  _ratingNumber(newRating, context, highlight: true),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: gained
                            ? [const Color(0xFF34D399), const Color(0xFF059669)]
                            : neutral
                            ? [const Color(0xFF64748B), const Color(0xFF475569)]
                            : [
                                const Color(0xFFF87171),
                                const Color(0xFFB91C1C),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (gained
                                      ? const Color(0xFF059669)
                                      : neutral
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFB91C1C))
                                  .withOpacity(.55),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      (gained ? '+' : (neutral ? '' : '−')) +
                          (delta.abs()).toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ratingNumber(
    int value,
    BuildContext context, {
    bool highlight = false,
  }) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        colors: highlight
            ? [const Color(0xFFFFFFFF), const Color(0xFFBAE6FD)]
            : [Colors.white.withOpacity(.85), Colors.white70],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text(
        value.toString(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
