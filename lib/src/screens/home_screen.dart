import 'package:flutter/material.dart';
import 'dart:math' as math; // for space card star field
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/game_controller.dart';
import '../controllers/profile_controller.dart';
import '../features/home/models/quick_stat.dart';
import '../features/home/widgets/glass_card.dart';
import '../features/home/widgets/quick_stat_tile.dart';
import '../features/home/widgets/difficulty_carousel.dart';
import '../features/home/widgets/entrance_transition.dart';
import '../features/home/widgets/top_players_preview.dart';
import '../features/home/widgets/recent_item.dart';
import '../features/home/widgets/recent_placeholder.dart';
import '../features/home/widgets/leaderboard_hint.dart';
import '../features/home/widgets/profile_fab.dart';
import '../features/home/widgets/game_modes_info_sheet.dart';
import 'game_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _heroController = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 1800,
    ), // match leaderboard intro speed
  )..forward();
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
    lowerBound: 0.85,
    upperBound: 1.0,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _heroController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .displaySmall!
      .copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.0, height: 0.95);

  TextStyle _subtitleStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium!
      .copyWith(color: Colors.white.withOpacity(0.85), letterSpacing: 0.2);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context, listen: false);
    final profileController = context.watch<ProfileController>();
    final profile = profileController.profile;
    final recent = profileController.recentGames;
    final user = FirebaseAuth.instance.currentUser;

    // aggregate quick stats
    String games = '—';
    String wins = '—';
    String winPct = '—';
    String avg = '—';
    if (profile != null) {
      final gp =
          profile.easy.gamesPlayed +
          profile.medium.gamesPlayed +
          profile.hard.gamesPlayed;
      final w = profile.easy.wins + profile.medium.wins + profile.hard.wins;
      final pct = gp == 0 ? 0 : (w / gp * 100);
      final avgSeconds = w == 0
          ? 0
          : ((profile.easy.totalSeconds +
                        profile.medium.totalSeconds +
                        profile.hard.totalSeconds) /
                    w)
                .round();
      games = gp.toString();
      wins = w.toString();
      winPct = '${pct.toStringAsFixed(1)}%';
      if (avgSeconds > 0) {
        final m = avgSeconds ~/ 60;
        final s = avgSeconds % 60;
        avg = '${m}m ${s}s';
      }
    }

    String format(dynamic ts, dynamic seconds) {
      DateTime? dt;
      if (ts is Timestamp) {
        dt = ts.toDate();
      } else if (ts is DateTime) {
        dt = ts;
      }
      final sec = (seconds is num) ? seconds.toInt() : 0;
      final dateStr = dt != null
          ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
          : '—';
      final m = sec ~/ 60;
      final s = sec % 60;
      final timeStr = sec > 0 ? '${m}m ${s}s' : '';
      return [dateStr, timeStr].where((e) => e.isNotEmpty).join(' · ');
    }

    final quickStats = [
      QuickStat(
        label: 'Games',
        value: games,
        color: const Color(0xFF38BDF8),
        icon: Icons.sports_esports,
      ),
      QuickStat(
        label: 'Wins',
        value: wins,
        color: const Color(0xFF4ADE80),
        icon: Icons.emoji_events_rounded,
      ),
      QuickStat(
        label: 'Win %',
        value: winPct,
        color: const Color(0xFFA78BFA),
        icon: Icons.pie_chart_rounded,
      ),
      QuickStat(
        label: 'Avg',
        value: avg,
        color: const Color(0xFFFBBF24),
        icon: Icons.timer_rounded,
      ),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const _AnimatedBackground(),
          Positioned(
            right: -60,
            top: -40,
            child: _SoftBlob(
              size: 240,
              colors: const [Color(0xFF6366F1), Color(0xFF0EA5E9)],
              opacity: 0.25,
            ),
          ),
          Positioned(
            left: -70,
            bottom: -40,
            child: _SoftBlob(
              size: 280,
              colors: const [Color(0xFFFB7185), Color(0xFFF59E0B)],
              opacity: 0.20,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                28,
                20,
                12,
              ), // increased top padding for breathing room
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title + profile button aligned
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _heroController,
                          builder: (context, child) {
                            final v = CurvedAnimation(
                              parent: _heroController,
                              curve: const Interval(
                                0.0,
                                0.30,
                                curve: Curves.easeOutCubic,
                              ),
                            ).value;
                            final scale = 0.94 + 0.06 * v;
                            return Opacity(
                              opacity: v,
                              child: Transform.translate(
                                offset: Offset(0, (1 - v) * 28),
                                child: Transform.scale(
                                  scale: scale,
                                  alignment: Alignment.topLeft,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: _HeroHeader(
                            greeting: _greeting(),
                            name: user?.displayName ?? 'Player',
                            titleStyle: _titleStyle(context),
                            subtitleStyle: _subtitleStyle(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ScaleTransition(
                        scale: _pulseController,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: const ProfileFab(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Replaced flat horizontal list with a curved "rainbow" arc layout
                  QuickStatsArc(stats: quickStats, controller: _heroController),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        EntranceTransition(
                          controller: _heroController,
                          start: .15,
                          end: .40,
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flash_on_rounded,
                                      color: Colors.amber, // simplified
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Play Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: 'Game Modes Info',
                                      icon: const Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () async {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          builder: (_) =>
                                              const GameModesInfoSheet(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                DifficultyCarousel(
                                  onSelect: (size) {
                                    controller.newGame(size: size);
                                    Navigator.pushNamed(
                                      context,
                                      GameScreen.routeName,
                                    );
                                  },
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (profile == null ||
                            (profile.easy.gamesPlayed +
                                    profile.medium.gamesPlayed +
                                    profile.hard.gamesPlayed) ==
                                0)
                          EntranceTransition(
                            controller: _heroController,
                            start: .22,
                            end: .50,
                            child: const GlassCard(child: LeaderboardHint()),
                          ),
                        if (profile == null ||
                            (profile.easy.gamesPlayed +
                                    profile.medium.gamesPlayed +
                                    profile.hard.gamesPlayed) ==
                                0)
                          const SizedBox(height: 22),
                        // Top Players preview
                        EntranceTransition(
                          controller: _heroController,
                          start: .30,
                          end: .60,
                          child: _SpaceCard(child: TopPlayersPreview()),
                        ),
                        const SizedBox(height: 22),
                        EntranceTransition(
                          controller: _heroController,
                          start: .45,
                          end: .75,
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      color: Colors.cyanAccent,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Recent Activity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),
                                if (recent.isEmpty) ...[
                                  Text(
                                    'Your latest games will appear here once you start playing.',
                                    style: TextStyle(color: Colors.white60),
                                  ),
                                  SizedBox(height: 18),
                                  const RecentPlaceholder(),
                                ] else ...[
                                  for (final g in recent.take(5))
                                    RecentItem(
                                      title:
                                          '${(g['level'] ?? '?').toString().toUpperCase()} - ${(g['win'] == true) ? 'WIN' : 'LOSS'}',
                                      subtitle: format(g['ts'], g['seconds']),
                                      win: g['win'] == true,
                                    ),
                                  if (recent.length > 5)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ProfileScreen(),
                                              ),
                                            ),
                                        child: const Text('View All'),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 90),
                      ],
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}

// Simple animated background placeholder
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// Decorative animated soft blob
class _SoftBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;
  const _SoftBlob({
    required this.size,
    required this.colors,
    this.opacity = 0.25,
  });
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              for (final c in colors) c.withOpacity(opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String greeting; // retained but unused visually
  final String name;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle; // retained for potential future use
  const _HeroHeader({
    required this.greeting,
    required this.name,
    required this.titleStyle,
    required this.subtitleStyle,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated fancy title replacing static white text
        AnimatedTitle(
          text: 'Sudoku (数独)',
          style: titleStyle.copyWith(letterSpacing: -0.8),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back, $name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// Animated gradient shimmer title (no movement of glyph positions)
class AnimatedTitle extends StatefulWidget {
  final String text;
  final TextStyle style;
  const AnimatedTitle({super.key, required this.text, required this.style});
  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value; // 0..1
        final slide = (t * 2) - 1; // -1..1 for continuous horizontal loop
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: const [
              Color(0xFFFFFFFF),
              Color(0xFFBAE6FD),
              Color(0xFF60A5FA),
              Color(0xFFF0ABFC),
            ],
            stops: const [0.0, 0.45, 0.7, 1.0],
            begin: Alignment(-1 + slide, 0),
            end: Alignment(1 + slide, 0),
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: widget.style.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}

class QuickStatsArc extends StatelessWidget {
  final List<QuickStat> stats;
  final AnimationController controller;
  const QuickStatsArc({
    super.key,
    required this.stats,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    // Manual stacked layout (based on provided screenshot):
    // - Left -> right cards with overlap.
    // - Z-order: later (right) tiles on top.
    // - Slight individual rotations & vertical offsets for playful cascade.
    return SizedBox(
      height: 160,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const nominalTileWidth = 140.0;
          const tileHeight = 84.0;
          final count = stats.length;
          if (count == 0) return const SizedBox.shrink();

          // Desired overlap ratio between consecutive tiles (e.g., 35% overlap => spacing = width * (1 - 0.35)).
          const overlapRatio = 0.35; // 35% horizontal overlap
          double tileWidth = nominalTileWidth;
          double spacing = tileWidth * (1 - overlapRatio);
          final totalWidthNeeded = tileWidth + (count - 1) * spacing;
          if (totalWidthNeeded > width) {
            // Scale down proportionally to fit.
            final scale = width / totalWidthNeeded;
            tileWidth *= scale;
            spacing *= scale;
          }

          // Manual per-index adjustments based on screenshot feel.
          // Vertical (top) offset deltas and rotation (radians).
          final topBase = 28.0; // baseline top for second tile (approx)
          final topAdjust = <double>[
            -5,
            29,
            -12,
            25,
          ]; // games -5, wins +12 (down), win% +2, avg +3
          final rotations = <double>[
            0.09,
            -0.08,
            0.04,
            -0.15,
          ]; // updated angles matching reference

          final children = <Widget>[];
          for (int i = 0; i < count; i++) {
            final stat = stats[i];
            double left = i * spacing; // left position of tile
            if (i == 0) left -= 12; // nudge Games tile further left
            if (i == count - 1) left += 12; // nudge Avg tile further right
            final top = topBase + topAdjust[i.clamp(0, topAdjust.length - 1)];
            final rotation = rotations[i.clamp(0, rotations.length - 1)];

            // Entrance animation staggering.
            final start = 0.10 + i * 0.05;
            final end = (start + 0.40).clamp(0.0, 1.0);
            final anim = CurvedAnimation(
              parent: controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            );

            children.add(
              AnimatedBuilder(
                animation: anim,
                builder: (context, _) {
                  final v = anim.value;
                  final drop = (1 - v) * 30;
                  return Positioned(
                    left: left,
                    top: top + drop,
                    width: tileWidth,
                    height: tileHeight,
                    child: Opacity(
                      opacity: v,
                      child: Transform.rotate(
                        angle: rotation * v, // ease rotation in
                        child: Transform.scale(
                          scale: 0.92 + 0.08 * v,
                          alignment: Alignment.center,
                          child: QuickStatTile(
                            stat: stat,
                            index: i,
                            animation: anim,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Subtle soft backdrop behind group
              Positioned(
                left: 0,
                top: 10,
                right: 0,
                height: tileHeight + 60,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.04),
                          Colors.white.withOpacity(0.00),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ...children, // order ensures rightmost drawn last (on top)
            ],
          );
        },
      ),
    );
  }
}

// Add space themed card widget
class _SpaceCard extends StatelessWidget {
  final Widget child;
  const _SpaceCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090B18), Color(0xFF0F1530), Color(0xFF111D3F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.6),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF5C6BC0).withOpacity(.15),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.08), width: 1.2),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // star field overlay
          Positioned.fill(child: CustomPaint(painter: _StarFieldPainter())),
          // subtle radial glow center
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.1,
                  colors: [
                    Colors.deepPurple.withOpacity(.18),
                    Colors.transparent,
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  static final _random = math.Random(1337);
  final List<Offset> _stars = List.generate(
    70,
    (i) => Offset(_random.nextDouble(), _random.nextDouble()),
  );
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _stars.length; i++) {
      final o = _stars[i];
      final dx = o.dx * size.width;
      final dy = o.dy * size.height;
      final r = (i % 7 == 0)
          ? 1.6
          : (i % 11 == 0)
          ? 1.3
          : 1.0;
      paint.color = Colors.white.withOpacity(.15 + (i % 5) * 0.07);
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
