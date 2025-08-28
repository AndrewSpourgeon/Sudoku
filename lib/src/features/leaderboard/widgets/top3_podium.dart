import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';

/// Public widget used by the leaderboard screen.
class Top3Podium extends StatefulWidget {
  final LeaderboardEntry first;
  final LeaderboardEntry second;
  final LeaderboardEntry third;
  final String? myUid;
  const Top3Podium({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.myUid,
  });

  @override
  State<Top3Podium> createState() => _Top3PodiumState();
}

class _Top3PodiumState extends State<Top3Podium> with TickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    // Kick off entrance animation
    _intro.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 18),
      child: LayoutBuilder(
        builder: (context, c) {
          final columnWidth =
              (c.maxWidth - 40) / 3; // spacing between three blocks
          return SizedBox(
            width: c.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background light wedges behind center podium
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) {
                      final pulse = 0.55 + sin(_anim.value * pi * 2) * 0.15;
                      return CustomPaint(painter: _BeamPainter(opacity: pulse));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PodiumColumn(
                      entry: widget.second,
                      rank: 2,
                      height: 120,
                      width: columnWidth,
                      highlight: widget.second.uid == widget.myUid,
                      anim: _anim,
                      intro: _intro,
                      order: 0,
                    ),
                    _PodiumColumn(
                      entry: widget.first,
                      rank: 1,
                      height: 150,
                      width: columnWidth,
                      highlight: widget.first.uid == widget.myUid,
                      anim: _anim,
                      intro: _intro,
                      order: 1,
                    ),
                    _PodiumColumn(
                      entry: widget.third,
                      rank: 3,
                      height: 105,
                      width: columnWidth,
                      highlight: widget.third.uid == widget.myUid,
                      anim: _anim,
                      intro: _intro,
                      order: 2,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final double width;
  final bool highlight;
  final Animation<double> anim;
  final Animation<double> intro;
  final int order; // for stagger
  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.height,
    required this.width,
    required this.highlight,
    required this.anim,
    required this.intro,
    required this.order,
  });

  List<Color> get _colors => switch (rank) {
    1 => const [Color(0xFFFFD948), Color(0xFFF6B800)],
    2 => const [Color(0xFFE3E8F0), Color(0xFFB5BDC8)],
    3 => const [Color(0xFFE6A067), Color(0xFFBF6A21)],
    _ => const [Colors.blueGrey, Color(0xFF45515B)],
  };

  @override
  Widget build(BuildContext context) {
    final name = (entry.displayName ?? 'Player').split(' ').first;
    final rating = entry.globalRating;
    final winPct = entry.winPercent; // 0..1
    final photo = entry.photoUrl;
    final colors = _colors;

    return SizedBox(
      width: width,
      child: AnimatedBuilder(
        animation: intro,
        builder: (context, _) {
          double baseDelay = order * 0.08; // stagger start
          // Slow overall timing: expand stagger slightly when duration increased
          baseDelay = order * 0.12;
          double podiumStart = baseDelay;
          double podiumEnd = (baseDelay + 0.45).clamp(0.0, 1.0);
          double avatarStart = (baseDelay + 0.35).clamp(0.0, 1.0);
          double avatarEnd = (baseDelay + 0.75).clamp(0.0, 1.0);
          double nameStart = (baseDelay + 0.42).clamp(0.0, 1.0);
          double nameEnd = (baseDelay + 0.82).clamp(0.0, 1.0);

          double v(double s, double e, Curve curve) {
            final t = intro.value;
            if (t <= s) return 0;
            if (t >= e) return 1;
            final norm = (t - s) / max(0.0001, (e - s));
            return curve.transform(norm.clamp(0.0, 1.0));
          }

          final podiumT = v(podiumStart, podiumEnd, Curves.easeOutBack);
          final avatarT = v(avatarStart, avatarEnd, Curves.easeOut);
          final nameT = v(nameStart, nameEnd, Curves.easeOut);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar (slides up & fades in after podium grows)
              Opacity(
                opacity: avatarT,
                child: Transform.translate(
                  offset: Offset(0, (1 - avatarT) * 24),
                  child: _AvatarWithStars(
                    photoUrl: photo,
                    fallback: name.isEmpty ? '?' : name[0].toUpperCase(),
                    borderColor: colors.first,
                    anim: anim,
                    big: rank == 1,
                    highlight: highlight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Name (slight fade & slide)
              Opacity(
                opacity: nameT,
                child: Transform.translate(
                  offset: Offset(0, (1 - nameT) * 12),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Podium growing from bottom (scale Y)
              _PodiumBlock(
                rank: rank,
                rating: rating,
                winPercent: winPct,
                height: height,
                colors: colors,
                appear: podiumT,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  final int rank;
  final int rating;
  final double winPercent; // 0..1
  final double height;
  final List<Color> colors;
  final double appear; // 0..1 animation factor
  const _PodiumBlock({
    required this.rank,
    required this.rating,
    required this.winPercent,
    required this.height,
    required this.colors,
    required this.appear,
  });

  @override
  Widget build(BuildContext context) {
    final rankLabel = switch (rank) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '#$rank',
    };
    final pctStr = '${(winPercent * 100).clamp(0, 100).toStringAsFixed(1)}%';

    // Simple 2D podium: flat front face only, no right face or top face
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // subtle ground shadow to anchor the block
          Positioned(
            left: 6,
            right: 6,
            bottom: -10,
            height: 16,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.4),
                    radius: 0.9,
                    colors: [
                      Colors.black.withOpacity(0.28 * appear),
                      Colors.black.withOpacity(0.03 * appear),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Flat front face (scale from bottom)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..scale(1.0, max(0.0001, appear), 1.0)
                ..translate(0.0, (1 - appear) * 12),
              child: Opacity(
                opacity: appear.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18 * appear),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: appear.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, (1 - appear) * 8),
                            child: Text(
                              rankLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * appear),
                        Opacity(
                          opacity: appear.clamp(0, 1),
                          child: Transform.translate(
                            offset: Offset(0, (1 - appear) * 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${rating}p',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      letterSpacing: .3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pctStr,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      letterSpacing: .3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarWithStars extends StatelessWidget {
  final String? photoUrl;
  final String fallback;
  final Color borderColor;
  final Animation<double> anim;
  final bool big;
  final bool highlight;
  const _AvatarWithStars({
    required this.photoUrl,
    required this.fallback,
    required this.borderColor,
    required this.anim,
    required this.big,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final size = big ? 82.0 : 70.0;
    return SizedBox(
      height: size + 30,
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Flickering stars
              for (var i = 0; i < 6; i++)
                _AnimatedStar(
                  anim: anim,
                  index: i,
                  orbitRadius: size * 0.75,
                  color: borderColor,
                  big: big,
                ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [borderColor, borderColor.withOpacity(.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: highlight
                        ? Colors.amberAccent
                        : Colors.white.withOpacity(.70),
                    width: highlight ? 3.2 : 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(.55),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, _, __) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fallbackAvatar() => Container(
    color: Colors.black26,
    alignment: Alignment.center,
    child: Text(
      fallback,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _AnimatedStar extends StatelessWidget {
  final Animation<double> anim;
  final int index;
  final double orbitRadius;
  final Color color;
  final bool big;
  const _AnimatedStar({
    required this.anim,
    required this.index,
    required this.orbitRadius,
    required this.color,
    required this.big,
  });
  @override
  Widget build(BuildContext context) {
    final baseAngle = (pi * 2 / 6) * index;
    final angle = baseAngle + anim.value * pi * 2;
    final dx = cos(angle) * orbitRadius;
    final dy = sin(angle) * orbitRadius;
    final pulse = (sin((anim.value + index * 0.15) * pi * 2) * 0.5 + 0.5);
    final size = (big ? 11.0 : 9.0) + pulse * 2.0;
    return Positioned(
      left: dx + 0,
      top: dy + 0,
      child: Opacity(
        opacity: 0.25 + pulse * 0.75,
        child: Transform.scale(
          scale: 0.7 + pulse * 0.3,
          child: Icon(Icons.star_rounded, size: size, color: color),
        ),
      ),
    );
  }
}

class _BeamPainter extends CustomPainter {
  final double opacity;
  const _BeamPainter({required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 0);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          Colors.white.withOpacity(opacity * 0.35),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: size.height * .9));

    // Two overlapping wedges to mimic beam spread
    final path1 = Path()
      ..moveTo(size.width * 0.33, size.height * 0.0)
      ..lineTo(size.width * 0.48, size.height * 0.55)
      ..lineTo(size.width * 0.52, size.height * 0.55)
      ..close();
    final path2 = Path()
      ..moveTo(size.width * 0.67, size.height * 0.0)
      ..lineTo(size.width * 0.52, size.height * 0.55)
      ..lineTo(size.width * 0.48, size.height * 0.55)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _BeamPainter old) => old.opacity != opacity;
}
