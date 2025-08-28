import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';

class TopPlayerRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  const TopPlayerRow({super.key, required this.rank, required this.entry});
  @override
  Widget build(BuildContext context) {
    final gradient = switch (rank) {
      1 => const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFE680)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      2 => const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFFE0E0E0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      3 => const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFFE5A15C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      _ => const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };

    final name = (entry.displayName ?? 'Player').trim();
    final firstName = name.contains(' ') ? name.split(' ').first : name;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.14), width: 1.1),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.25),
            Colors.white.withOpacity(.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.55),
            blurRadius: 30,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(-6, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _MiniRankCircle(rank: rank),
                const SizedBox(width: 12),
                _Avatar(photoUrl: entry.photoUrl, rank: rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _WinRateBar(percent: entry.winPercent),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _RatingPill(rating: entry.globalRating, gradient: gradient),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final int rank;
  const _Avatar({required this.photoUrl, required this.rank});
  @override
  Widget build(BuildContext context) {
    final ringGradient = switch (rank) {
      1 => const [Color(0xFFFFF59E), Color(0xFFFFD700)],
      2 => const [Color(0xFFE2E8F0), Color(0xFFC0C0C0)],
      3 => const [Color(0xFFF6AD55), Color(0xFFCD7F32)],
      _ => const [Color(0xFF38BDF8), Color(0xFF6366F1)],
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: ringGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ringGradient.last.withOpacity(.55),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.08),
          border: Border.all(color: Colors.white.withOpacity(.25), width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: photoUrl != null
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => const Icon(Icons.person_rounded, color: Colors.white54);
}

class _RatingPill extends StatelessWidget {
  final int rating;
  final Gradient gradient;
  const _RatingPill({required this.rating, required this.gradient});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        rating.toString(),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _WinRateBar extends StatelessWidget {
  final double percent; // 0..1
  const _WinRateBar({required this.percent});
  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 1);
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withOpacity(.12),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * p,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRankCircle extends StatelessWidget {
  final int rank;
  const _MiniRankCircle({required this.rank});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (rank) {
      case 1:
        color = const Color(0xFFFFD700);
        break;
      case 2:
        color = const Color(0xFFC0C0C0);
        break;
      case 3:
        color = const Color(0xFFCD7F32);
        break;
      default:
        color = Colors.white.withOpacity(.30);
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withOpacity(.55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.55),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(rank <= 3 ? 0.55 : 0.25),
          width: 1.1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: TextStyle(
          color: rank <= 3 ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
