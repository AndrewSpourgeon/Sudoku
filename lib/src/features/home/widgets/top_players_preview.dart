import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../repositories/user_repository.dart';
import '../../../models/leaderboard_entry.dart';

class TopPlayersPreview extends StatelessWidget {
  final _repo = UserRepository();
  TopPlayersPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: Colors.pinkAccent.shade100,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'Top Players',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See All'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<LeaderboardEntry>>(
          // Fetch more than 3 so tie-breaking (rating + win%) is correct before trimming
          stream: _repo.leaderboardStream(limit: 50),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingRow();
            }
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Text(
                'No players yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
              );
            }
            // Defensive re-sort (repo already sorts) to ensure correct ordering when ties exist
            final sorted = [...data];
            sorted.sort((a, b) {
              final ratingCmp = b.globalRating.compareTo(a.globalRating);
              if (ratingCmp != 0) return ratingCmp;
              return b.winPercent.compareTo(a.winPercent);
            });
            return SizedBox(
              height: 190, // was 170
              child: _OrbitingTopPlayers(entries: sorted.take(3).toList()),
            );
          },
        ),
      ],
    );
  }
}

class _LoadingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, // enlarged
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(.18),
                    Colors.white.withOpacity(.05),
                  ],
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 78,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Remove old animated list + avatar classes and replace with orbit animation
class _OrbitingTopPlayers extends StatefulWidget {
  final List<LeaderboardEntry> entries;
  const _OrbitingTopPlayers({required this.entries});
  @override
  State<_OrbitingTopPlayers> createState() => _OrbitingTopPlayersState();
}

class _OrbitingTopPlayersState extends State<_OrbitingTopPlayers>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // Slower orbit: was 2000ms per player -> now 4000ms per player (e.g. 3 players = 12s per full revolution)
    duration: Duration(milliseconds: 4000 * math.max(widget.entries.length, 1)),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries; // already trimmed & correctly ordered
    final n = entries.length;
    if (n == 1) {
      final e = entries.first;
      return SizedBox(
        height: 190,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 138, // was 124
              child: Center(
                child: _OrbitAvatar(
                  entry: e,
                  rank: 1,
                  scale: 1,
                  elevation: 8,
                  opacity: 1,
                  highlighted: true,
                ),
              ),
            ),
            _HighlightedName(name: (e.displayName ?? 'Player').trim(), rank: 1),
          ],
        ),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value; // 0-1 over full cycle
        int frontIndex = 0;
        double maxDepth = -1;
        final center = const Offset(0, 0);
        const radiusX = 95.0; // was 90
        const radiusY = 32.0; // was 30
        final List<_OrbitItem> items = [];
        for (int i = 0; i < n; i++) {
          final baseAngle = 2 * math.pi * i / n;
          final angle = (2 * math.pi * t) + baseAngle; // rotating
          final x = math.cos(angle) * radiusX;
          final y = math.sin(angle) * radiusY; // y depth
          final depth = (y + radiusY) / (2 * radiusY); // 0 (back) ..1 (front)
          final scale = lerpDouble(0.55, 1.05, depth)!;
          final elev = lerpDouble(0, 16, depth)!;
          final opacity = lerpDouble(0.30, 1.0, depth)!;
          if (depth > maxDepth) {
            maxDepth = depth;
            frontIndex = i;
          }
          items.add(
            _OrbitItem(
              depth: depth,
              widget: Transform.translate(
                offset: Offset(
                  center.dx + x,
                  center.dy + y - 8,
                ), // lift orbit 2px to prevent overflow
                child: Transform.scale(
                  scale: scale,
                  child: _OrbitAvatar(
                    entry: entries[i],
                    rank: i + 1,
                    scale: scale,
                    elevation: elev,
                    opacity: opacity,
                    highlighted: i == frontIndex,
                  ),
                ),
              ),
            ),
          );
        }
        // sort so back drawn first
        items.sort((a, b) => a.depth.compareTo(b.depth));
        final highlightEntry = entries[frontIndex];
        return Center(
          child: SizedBox(
            height: 190, // was 170
            width: 260, // a bit wider to accommodate larger avatars
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 138, // was 124
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        child: CustomPaint(
                          size: const Size(230, 82), // enlarged path
                          painter: _OrbitPathPainter(),
                        ),
                      ),
                      for (final it in items) it.widget,
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _HighlightedName(
                    key: ValueKey(frontIndex),
                    name: (highlightEntry.displayName ?? 'Player').trim(),
                    rank: frontIndex + 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

class _OrbitItem {
  final double depth;
  final Widget widget;
  _OrbitItem({required this.depth, required this.widget});
}

class _OrbitAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double scale;
  final double elevation;
  final double opacity;
  final bool highlighted;
  const _OrbitAvatar({
    required this.entry,
    required this.rank,
    required this.scale,
    required this.elevation,
    required this.opacity,
    this.highlighted = false,
  });
  @override
  Widget build(BuildContext context) {
    final firstName = (entry.displayName ?? 'Player').split(' ').first;
    // Border (thin outline) color depends on rank (when highlighted) instead of always white
    Color rankColor(int r) => switch (r) {
      1 => const Color(0xFFFFD700), // gold
      2 => const Color(0xFFC0C0C0), // silver
      3 => const Color(0xFFCD7F32), // bronze
      _ => const Color(0xFF6366F1), // accent for others
    };
    final base = rankColor(rank);
    final borderColor = highlighted ? base : base.withOpacity(.30);

    Widget avatar;
    if (entry.photoUrl != null) {
      avatar = Container(
        width: 80, // was 72
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
          image: DecorationImage(
            image: NetworkImage(entry.photoUrl!),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          boxShadow: [
            if (highlighted)
              BoxShadow(
                color: Colors.white.withOpacity(.35),
                blurRadius: 24, // slightly larger for bigger avatar
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 20,
              offset: Offset(0, elevation * .2),
            ),
          ],
        ),
      );
    } else {
      avatar = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
          color: Colors.white.withOpacity(.05),
          boxShadow: [
            if (highlighted)
              BoxShadow(
                color: Colors.white.withOpacity(.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 20,
              offset: Offset(0, elevation * .2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _initials(firstName),
      );
    }
    return Opacity(
      opacity: opacity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(bottom: 0, right: -4, child: _RankBadge(rank: rank)),
        ],
      ),
    );
  }

  Widget _initials(String name) => Center(
    child: Text(
      name.isEmpty ? '?' : name[0].toUpperCase(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _HighlightedName extends StatelessWidget {
  final String name;
  final int rank;
  const _HighlightedName({required this.name, required this.rank, super.key});
  Color rankColor(int r) => switch (r) {
    1 => const Color(0xFFFFD700),
    2 => const Color(0xFFC0C0C0),
    3 => const Color(0xFFCD7F32),
    _ => const Color(0xFF6366F1),
  };
  @override
  Widget build(BuildContext context) {
    final color = rankColor(rank);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ), // reduced size
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(26), // slightly smaller radius
        border: Border.all(color: Colors.white.withOpacity(.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 16, // reduced from 18
          letterSpacing: 0.25,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});
  @override
  Widget build(BuildContext context) {
    final bg = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => const Color(0xFF6366F1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(.50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.55), width: 1),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: rank <= 3 ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _OrbitPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(.05),
          Colors.white.withOpacity(.12),
          Colors.white.withOpacity(.05),
        ],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
