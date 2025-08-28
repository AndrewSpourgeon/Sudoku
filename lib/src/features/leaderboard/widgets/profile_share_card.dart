import 'package:flutter/material.dart';

class ProfileShareCard extends StatelessWidget {
  final String name;
  final int rank;
  final int rating;
  final String? photoUrl;
  final int? fastestSeconds; // optional
  final int? bestRating; // can differ if historical
  final int? streakDays; // optional placeholder
  final int? bestRank; // peak rank
  const ProfileShareCard({
    super.key,
    required this.name,
    required this.rank,
    required this.rating,
    required this.photoUrl,
    this.fastestSeconds,
    this.bestRating,
    this.streakDays,
    this.bestRank,
  });
  String _formatFast(int? secs) {
    if (secs == null || secs <= 0) return '--';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final (accent, medalAsset) = switch (rank) {
      1 => (const Color(0xFFFFD700), 'assets/images/gold.png'),
      2 => (const Color(0xFFC0C0C0), 'assets/images/silver.png'),
      3 => (const Color(0xFFCD7F32), 'assets/images/bronze.png'),
      _ => (const Color(0xFF6366F1), null),
    };
    final theme = Theme.of(context);
    final baseTitle = theme.textTheme.headlineMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
      fontSize: 54,
    );
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: Colors.white.withOpacity(.70),
      letterSpacing: 1.5,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(.08), width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowCircle(color: accent.withOpacity(.45), size: 340),
          ),
          Positioned(
            bottom: -140,
            right: -60,
            child: _GlowCircle(
              color: Colors.pinkAccent.withOpacity(.35),
              size: 320,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ShareCardRings(accent: accent)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              accent.withOpacity(.95),
                              accent.withOpacity(.55),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(.30),
                            width: 3,
                          ),
                          boxShadow: [
                            // Intense inner glow
                            BoxShadow(
                              color: accent.withOpacity(.75),
                              blurRadius: 42,
                              spreadRadius: 4,
                            ),
                            // Medium aura
                            BoxShadow(
                              color: accent.withOpacity(.55),
                              blurRadius: 90,
                              spreadRadius: 10,
                            ),
                            // Wide soft halo
                            BoxShadow(
                              color: accent.withOpacity(.35),
                              blurRadius: 140,
                              spreadRadius: 18,
                            ),
                          ],
                          image: photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: photoUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontSize: 84,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -4,
                                ),
                              )
                            : null,
                      ),
                      if (medalAsset != null)
                        Positioned(
                          bottom: -28,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            medalAsset,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 72),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: baseTitle,
                  ),
                  const SizedBox(height: 28),
                  Text('GLOBAL RANK', style: labelStyle),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '#$rank',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -6,
                          color: accent,
                          shadows: [
                            Shadow(
                              color: accent.withOpacity(.8),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(.55),
                          blurRadius: 32,
                          offset: Offset(0, 14),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(.25),
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      'Rating  $rating',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _SnapshotGrid(
                    rank: rank,
                    rating: rating,
                    bestRating: bestRating ?? rating,
                    fastest: _formatFast(fastestSeconds),
                    streak: (streakDays ?? 0) > 0 ? '${streakDays}d' : '--',
                    bestRank: bestRank ?? rank,
                  ),
                  const SizedBox(height: 44),
                  Text(
                    'Sudoku Global Leaderboard',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(.90),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCardRings extends CustomPainter {
  final Color accent;
  _ShareCardRings({required this.accent});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final radii = [size.width * .18, size.width * .32, size.width * .46];
    for (final r in radii) {
      paint.shader = SweepGradient(
        colors: [
          Colors.white.withOpacity(.02),
          accent.withOpacity(.30),
          Colors.white.withOpacity(.02),
        ],
        stops: const [0.0, .55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShareCardRings oldDelegate) => false;
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

class _SnapshotGrid extends StatelessWidget {
  final int rank;
  final int rating;
  final int bestRating;
  final String fastest;
  final String streak;
  final int bestRank;
  const _SnapshotGrid({
    required this.rank,
    required this.rating,
    required this.bestRating,
    required this.fastest,
    required this.streak,
    required this.bestRank,
  });
  @override
  Widget build(BuildContext context) {
    final badgeData = [
      _Badge(icon: Icons.flash_on_rounded, label: 'STREAK', value: streak),
      _Badge(
        icon: Icons.emoji_events_rounded,
        label: 'BEST RANK',
        value: '#$bestRank',
      ),
      _Badge(
        icon: Icons.auto_graph_rounded,
        label: 'BEST RATING',
        value: bestRating.toString(),
      ),
      _Badge(icon: Icons.timer_rounded, label: 'FAST WIN', value: fastest),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final badgeWidth = (width - 36) / 2; // 12 + 12 + 12 gaps
        return Wrap(
          runSpacing: 12,
          spacing: 12,
          children: [
            for (final b in badgeData)
              SizedBox(
                width: badgeWidth,
                child: _SnapshotBadge(data: b),
              ),
          ],
        );
      },
    );
  }
}

class _Badge {
  final IconData icon;
  final String label;
  final String value;
  _Badge({required this.icon, required this.label, required this.value});
}

class _SnapshotBadge extends StatelessWidget {
  final _Badge data;
  const _SnapshotBadge({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF444B60).withOpacity(.92),
            const Color(0xFF2C313D).withOpacity(.90),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(.30), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.50),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(.55),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(.45),
                width: 1.0,
              ),
            ),
            child: Icon(data.icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Colors.white70,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: .2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
