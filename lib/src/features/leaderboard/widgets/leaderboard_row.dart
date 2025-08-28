import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';
import './player_avatar.dart';

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool highlight;
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.entry,
    required this.highlight,
  });
  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final isMe = highlight;
    final accent = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => Colors.white,
    };
    final containerGradient = isTop3
        ? LinearGradient(
            colors: [
              accent.withOpacity(.48), // brighter edge
              accent.withOpacity(.18), // richer mid tint
              Colors.white.withOpacity(.03),
            ],
            stops: const [0, .48, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : isMe
        ? const LinearGradient(
            colors: [Color(0x3306B6D4), Color(0x1A6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withOpacity(.12),
              Colors.white.withOpacity(.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final shadows = isTop3
        ? [
            // Removed outer accent glows; keep subtle depth only
            BoxShadow(
              color: Colors.black.withOpacity(.45),
              blurRadius: 26,
              offset: const Offset(0, 20),
            ),
          ]
        : isMe
        ? [
            BoxShadow(
              color: const Color(0xFF06B6D4).withOpacity(.75),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(.50),
              blurRadius: 70,
              spreadRadius: 10,
              offset: const Offset(0, 28),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.60),
              blurRadius: 28,
              offset: const Offset(0, 22),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.white.withOpacity(.06),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.55),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ];
    final borderColor = isTop3
        ? accent.withOpacity(.55)
        : isMe
        ? const Color(0xFF06B6D4).withOpacity(.75)
        : Colors.white.withOpacity(.10);
    final ratingWidget = Text(
      entry.globalRating.toString(),
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: isMe ? const Color(0xFFBAE6FD) : Colors.white,
      ),
    );
    final winPctStr = (entry.winPercent * 100).toStringAsFixed(1);
    final winWidget = Text(
      winPctStr,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: isMe ? const Color(0xFFBAE6FD) : Colors.white70,
      ),
    );
    final nameColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => isMe ? const Color(0xFFBAE6FD) : Colors.white,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isTop3 ? 1.2 : 1.0),
        gradient: containerGradient,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Stack(
            children: [
              if (isTop3)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withOpacity(.95),
                          accent.withOpacity(.55),
                          accent.withOpacity(0),
                        ],
                        stops: const [0, .45, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                      ),
                    ),
                  ),
                ),
              // Inner radial glow across row for top 3
              if (isTop3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accent.withOpacity(.75), // intense core
                            accent.withOpacity(.35),
                            accent.withOpacity(.08),
                          ],
                          stops: const [0.0, .55, 1.0],
                          center: Alignment.centerLeft,
                          radius: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTop3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accent.withOpacity(.75), // intense core (right)
                            accent.withOpacity(.35),
                            accent.withOpacity(.08),
                          ],
                          stops: const [0.0, .55, 1.0],
                          center: Alignment.centerRight,
                          radius: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTop3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [accent.withOpacity(.45), Colors.transparent],
                          radius: 2.2,
                          center: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTop3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accent.withOpacity(.25), // soft outer aura (right)
                            Colors.transparent,
                          ],
                          radius: 2.4,
                          center: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isTop3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accent.withOpacity(.18), // very soft outer aura
                            Colors.transparent,
                          ],
                          radius: 3.2,
                          center: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isTop3 && isMe)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF06B6D4).withOpacity(.95),
                          const Color(0xFF6366F1).withOpacity(.55),
                          Colors.transparent,
                        ],
                        stops: const [0, .55, 1],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Show medal badges for top 3, and player avatar with rank for others
                    SizedBox(
                      width: 44,
                      child: isTop3
                          ? _RankBadge(rank: rank)
                          : PlayerAvatar(
                              entry: entry,
                              rank: rank,
                              highlight: isMe,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Text(
                        entry.displayName ?? 'Player',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: nameColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          letterSpacing: .12,
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: ratingWidget),
                    const SizedBox(width: 10),
                    SizedBox(width: 60, child: winWidget),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatefulWidget {
  final int rank;
  const _RankBadge({required this.rank});
  @override
  State<_RankBadge> createState() => _RankBadgeState();
}

class _RankBadgeState extends State<_RankBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = widget.rank;
    final isTop3 = rank <= 3;
    final (accent, asset) = switch (rank) {
      1 => (const Color(0xFFFFD700), 'assets/images/gold.png'),
      2 => (const Color(0xFFC0C0C0), 'assets/images/silver.png'),
      3 => (const Color(0xFFCD7F32), 'assets/images/bronze.png'),
      _ => (Colors.white.withOpacity(.16), null),
    };
    final medalAsset = asset ?? '';
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final pulse = 0.96 + 0.04 * math.sin(t * 2 * math.pi);
        final rotate = t * 2 * math.pi;
        return SizedBox(
          height: 44,
          width: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isTop3)
                Transform.rotate(
                  angle: rotate,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          accent.withOpacity(.12),
                          accent.withOpacity(.85),
                          accent.withOpacity(.12),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              if (isTop3)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withOpacity(.85),
                      width: 1.4,
                    ),
                  ),
                ),
              Transform.scale(
                scale: isTop3 ? pulse : 1,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isTop3
                        ? LinearGradient(
                            colors: [
                              accent.withOpacity(.9),
                              accent.withOpacity(.55),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [accent, accent.withOpacity(.6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      // Primary tight glow
                      BoxShadow(
                        color: accent.withOpacity(isTop3 ? .70 : .25),
                        blurRadius: isTop3 ? 26 : 14,
                        spreadRadius: isTop3 ? 1 : 0,
                        offset: const Offset(0, 8),
                      ),
                      // Wider soft aura
                      if (isTop3)
                        BoxShadow(
                          color: accent.withOpacity(.55),
                          blurRadius: 50,
                          spreadRadius: 4,
                          offset: const Offset(0, 18),
                        ),
                      if (isTop3)
                        BoxShadow(
                          color: accent.withOpacity(.35),
                          blurRadius: 80,
                          spreadRadius: 8,
                          offset: const Offset(0, 26),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isTop3
                      ? Image.asset(
                          medalAsset,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          rank.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
