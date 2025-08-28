import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/profile_controller.dart';

class RankProgressCapsule extends StatefulWidget {
  final int? rank;
  final VoidCallback? onShare;
  const RankProgressCapsule({super.key, required this.rank, this.onShare});
  @override
  State<RankProgressCapsule> createState() => _RankProgressCapsuleState();
}

class _RankProgressCapsuleState extends State<RankProgressCapsule>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final r = widget.rank;
    if (r == null || r <= 0) return const SizedBox.shrink();
    final profile = context.watch<ProfileController>();

    final bestRank = profile.bestRank ?? r;
    final bestRating = profile.bestGlobalRating ?? profile.globalRating;
    final fastest = profile.fastestWinSeconds;
    final activityStreak = profile.currentStreak ?? 0; // activity streak

    String formatFast(int? seconds) {
      if (seconds == null || seconds <= 0) return '--';
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }

    final achievements = [
      _Achieve(
        icon: Icons.flash_on_rounded,
        label: 'Streak',
        value: activityStreak > 0 ? '${activityStreak}d' : '--',
      ),
      _Achieve(
        icon: Icons.emoji_events_rounded,
        label: 'Best Rank',
        value: '#$bestRank',
      ),
      _Achieve(
        icon: Icons.auto_graph_rounded,
        label: 'Best Rating',
        value: bestRating.toString(),
      ),
      _Achieve(
        icon: Icons.timer_rounded,
        label: 'Fast Win',
        value: formatFast(fastest),
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(18, 16, 18, _expanded ? 18 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1F29).withOpacity(.72),
            const Color(0xFF111218).withOpacity(.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(.18), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.55),
            blurRadius: 46,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
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
                    color: Colors.white.withOpacity(.30),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.leaderboard_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#$r',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(rect),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    _expanded ? 'Your Snapshot' : 'Snapshot card',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.2,
                    ),
                  ),
                ),
              ),
              if (widget.onShare != null && _expanded) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onShare,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(.55),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(.35),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.ios_share_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.30),
                        Colors.white.withOpacity(.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(.28)),
                  ),
                  child: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _AchievementBadge(data: achievements[0])),
                      const SizedBox(width: 12),
                      Expanded(child: _AchievementBadge(data: achievements[1])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _AchievementBadge(data: achievements[2])),
                      const SizedBox(width: 12),
                      Expanded(child: _AchievementBadge(data: achievements[3])),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 360),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _Achieve {
  final IconData icon;
  final String label;
  final String value;
  const _Achieve({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achieve data;
  const _AchievementBadge({required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            width: 36,
            height: 36,
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
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(.45),
                width: 1.0,
              ),
            ),
            child: Icon(data.icon, size: 18, color: Colors.white),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: .2,
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
