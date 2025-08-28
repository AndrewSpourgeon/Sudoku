import 'dart:math' as math; // added for animated gradients & ring painter

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../controllers/profile_controller.dart';
import '../features/profile/widgets/profile_glow_background.dart';
import '../features/profile/widgets/glass_panel.dart';
import '../features/profile/widgets/stat_chip.dart';
import '../features/profile/widgets/rank_row.dart';
import '../features/profile/widgets/sign_out_dialog.dart';
import '../features/profile/widgets/recent_profile_game.dart';
import '../features/profile/widgets/profile_performance_panel.dart';
import '../widgets/avatar_settings_sheet.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  static const double _expandedHeight =
      120; // reduced from 160 to start page higher
  // Unified app bar circular button sizing
  static const double _appBarBtnDim = 38;
  static const double _appBarBtnPad = 7.0;
  static const double _appBarActionDim =
      48; // slightly larger to match visual weight
  static const double _appBarActionPad = 8.0;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800), // match leaderboard pacing
  )..forward();
  late final AnimationController _bgController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  Future<void> _performSignOut() async {
    try {
      context.read<ProfileController>().reset();
      final google = GoogleSignIn();
      try {
        await google.signOut();
        await google.disconnect();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmSignOut() async {
    final result = await showSignOutDialog(context);
    if (result == true) {
      await _performSignOut();
    }
  }

  void _showPerformanceInfo() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF4C1D95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C1D95).withOpacity(.55),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(.06),
                blurRadius: 14,
                spreadRadius: -6,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(.18),
              width: 1.1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC084FC), Color(0xFFF9A8D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC084FC).withOpacity(.55),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Performance Trend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Line shows how long your recent games took. Lower dots = faster. Green dot = win, pink dot = loss.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => messenger.hideCurrentSnackBar(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Additional initialization if needed
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _openAvatarSettings(BuildContext context) {
    final profileController = context.read<ProfileController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return AvatarSettingsSheet(
          initialValue: profileController.profile?.allowAvatar,
          onSaved: (val) async {
            await profileController.updateAvatarConsent(val);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profileController = context.watch<ProfileController>();
    final profile = profileController.profile;
    final recent = profileController.recentGames;
    final globalRating =
        profileController.globalRating; // sum used for comparison
    final rank = profileController.rank; // actual ordinal rank
    final photo = user?.photoURL; // restored photo reference

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
      } else {
        avg = '—';
      }
    }

    final statsCards = [
      StatChip(
        label: 'Games',
        value: games,
        icon: Icons.sports_esports,
        color: const Color(0xFF38BDF8),
      ),
      StatChip(
        label: 'Wins',
        value: wins,
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFA78BFA), // swapped: was green
      ),
      StatChip(
        label: 'Win %',
        value: winPct,
        icon: Icons.pie_chart_rounded,
        color: const Color(0xFF4ADE80), // swapped: was purple
      ),
      StatChip(
        label: 'Avg Time',
        value: avg,
        icon: Icons.timer_rounded,
        color: const Color(0xFFFBBF24),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const ProfileGlowBackground(),
          // Floating soft particles
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              final particles = List.generate(18, (i) {
                final phase = (t + i / 18) % 1.0;
                final dx = Curves.easeInOut.transform(((phase + i * 0.07) % 1));
                final dy = ((phase + i * 0.13) % 1);
                final size =
                    12 + 24 * (0.5 + 0.5 * math.sin(phase * math.pi * 2));
                final opacity = 0.12 + 0.18 * math.sin(phase * math.pi * 2);
                return Positioned(
                  left: dx * MediaQuery.of(context).size.width - size / 2,
                  top: dy * MediaQuery.of(context).size.height * 0.55,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(opacity.clamp(0, .30)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              });
              return IgnorePointer(child: Stack(children: particles));
            },
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, c) {
                      final pct =
                          ((c.maxHeight - kToolbarHeight) /
                                  (_expandedHeight - kToolbarHeight))
                              .clamp(0.0, 1.0);
                      return ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          colors: [
                            const Color(0xFF0EA5E9).withOpacity(.65 * pct),
                            const Color(0xFF6366F1).withOpacity(.55 * pct),
                            const Color(0xFF9333EA).withOpacity(.40 * pct),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(rect),
                        blendMode: BlendMode.srcOver,
                        child: Container(decoration: const BoxDecoration()),
                      );
                    },
                  ),
                  leadingWidth: 56, // allow square space
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox.square(
                        dimension: _appBarBtnDim,
                        child: Container(
                          padding: const EdgeInsets.all(_appBarBtnPad),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(.38),
                                blurRadius: 10,
                                spreadRadius: -2,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(.30),
                                blurRadius: 8,
                                spreadRadius: -4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _openAvatarSettings(context);
                        },
                        child: SizedBox.square(
                          dimension: _appBarActionDim,
                          child: Container(
                            padding: const EdgeInsets.all(_appBarActionPad),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF59E0B),
                                  Color(0xFFEAB308),
                                ], // yellow gradient
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withOpacity(.46),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFFEAB308,
                                  ).withOpacity(.38),
                                  blurRadius: 10,
                                  spreadRadius: -4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.settings_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  title: AnimatedBuilder(
                    animation: _bgController,
                    builder: (_, __) {
                      final t = _bgController.value; // 0..1
                      final slide = (t * 2) - 1; // -1..1 for shimmer
                      return SizedBox(
                        height: 36,
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (r) => LinearGradient(
                              colors: const [
                                Color(0xFFFFFFFF),
                                Color(0xFFBAE6FD),
                                Color(0xFF60A5FA),
                                Color(0xFFF0ABFC),
                              ],
                              stops: const [0, .45, .7, 1],
                              begin: Alignment(-1 + slide, 0),
                              end: Alignment(1 + slide, 0),
                            ).createShader(r),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Profile',
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    fontSize: 20, // increased slightly
                                    color: Colors.white,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  centerTitle: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Header section (avatar + name) enhanced
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0, // was 8, move content further up
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'profile_fab',
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFF6366F1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65, // was 54
                                backgroundColor: Colors.black.withOpacity(0.6),
                                backgroundImage: photo != null
                                    ? NetworkImage(photo)
                                    : null,
                                child: photo == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 65, // match new radius
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12), // was 18
                          // Animated gradient display name
                          AnimatedBuilder(
                            animation: _bgController,
                            builder: (_, __) {
                              final slide = (_bgController.value * 2) - 1;
                              return ShaderMask(
                                shaderCallback: (r) => LinearGradient(
                                  colors: const [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFBAE6FD),
                                    Color(0xFF60A5FA),
                                    Color(0xFFF0ABFC),
                                  ],
                                  stops: const [0, .45, .7, 1],
                                  begin: Alignment(-1 + slide, 0),
                                  end: Alignment(1 + slide, 0),
                                ).createShader(r),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  user?.displayName ?? 'Player',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: 30, // increased name size
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Removed email display per request
                          // ...existing code...
                          // Removed non-functional quick action buttons
                          // const SizedBox(height: 16), // (optional extra spacing)
                          const SizedBox(height: 12),
                          GlassPanel(
                            title: 'Overview',
                            icon: Icons.dashboard_customize_rounded,
                            accent: const [
                              Color(0xFF38BDF8),
                              Color(0xFF6366F1),
                            ],
                            child: GridView.builder(
                              itemCount: statsCards.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.0,
                                  ),
                              itemBuilder: (context, i) => AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final v = CurvedAnimation(
                                    parent: _controller,
                                    curve: Interval(
                                      0.05 + i * 0.06,
                                      (0.35 + i * 0.06).clamp(0.0, 0.95),
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ).value;
                                  final scale = 0.90 + 0.10 * v;
                                  return Opacity(
                                    opacity: v,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - v) * 38),
                                      child: Transform.scale(
                                        scale: scale,
                                        alignment: Alignment.center,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: statsCards[i],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final v = CurvedAnimation(
                                parent: _controller,
                                curve: const Interval(
                                  0.15, // start after first stat chips begin
                                  0.50, // finish before Global Ranking animation
                                  curve: Curves.easeOutCubic,
                                ),
                              ).value;
                              final dx = (1 - v) * -70; // slide from left
                              final scale = 0.96 + 0.04 * v;
                              return Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.centerLeft,
                                    child: ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: v.clamp(
                                          0.0,
                                          1.0,
                                        ), // reveal from left
                                        child: child,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: GlassPanel(
                              title: 'Performance',
                              icon: Icons.show_chart_rounded,
                              accent: const [
                                Color(0xFFC084FC), // soft violet
                                Color(0xFFF9A8D4), // soft pink
                              ],
                              // icon stays default left; we add info button on right
                              headerAction: IconButton(
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: Colors.white70,
                                ),
                                tooltip: 'What is this?',
                                splashRadius: 20,
                                onPressed: () {
                                  _showPerformanceInfo();
                                },
                              ),
                              child: ProfilePerformancePanel(
                                recent: recent,
                                profile: profile,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final v = CurvedAnimation(
                                parent: _controller,
                                curve: const Interval(
                                  0.25,
                                  0.65,
                                  curve: Curves.easeOutCubic,
                                ),
                              ).value;
                              final scale = 0.92 + 0.08 * v;
                              return Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - v) * 46),
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.topCenter,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: GlassPanel(
                              title: 'Global Ranking',
                              icon: Icons.emoji_events_rounded,
                              accent: const [
                                Color(0xFFF59E0B),
                                Color(0xFFEAB308),
                              ],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RankRow(
                                    label: 'Global Rank',
                                    value: rank != null ? '# $rank' : '# …',
                                    icon: Icons.leaderboard_rounded,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                  RankRow(
                                    label: 'Global Rating (sum)',
                                    value: globalRating > 0
                                        ? globalRating.toString()
                                        : '—',
                                    icon: Icons.auto_graph_rounded,
                                    color: const Color(0xFF6366F1),
                                  ),
                                  RankRow(
                                    label: 'Easy Rating',
                                    value:
                                        profile?.easy.rating.toString() ?? '—',
                                    icon: Icons.light_mode_rounded,
                                    color: const Color(0xFF4ADE80),
                                  ),
                                  RankRow(
                                    label: 'Medium Rating',
                                    value:
                                        profile?.medium.rating.toString() ??
                                        '—',
                                    icon: Icons.terrain_rounded,
                                    color: const Color(0xFFFBBF24),
                                  ),
                                  RankRow(
                                    label: 'Hard Rating',
                                    value:
                                        profile?.hard.rating.toString() ?? '—',
                                    icon: Icons.nightlight_round_rounded,
                                    color: const Color(0xFFFB7185),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final v = CurvedAnimation(
                                parent: _controller,
                                curve: const Interval(
                                  0.55,
                                  0.90,
                                  curve: Curves.easeOutCubic,
                                ),
                              ).value;
                              final scale = 0.92 + 0.08 * v;
                              return Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - v) * 50),
                                  child: Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.topCenter,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: GlassPanel(
                              title: 'Recent Games',
                              icon: Icons.history_rounded,
                              accent: const [
                                Color(0xFF06B6D4),
                                Color(0xFF6366F1),
                              ],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (recent.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Text(
                                        'Play some games to build your history.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white60),
                                      ),
                                    ),
                                  for (final g in recent.take(8))
                                    RecentProfileGame(game: g),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Sign Out Button
                          SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFFB7185),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFEF4444,
                                      ).withOpacity(.42),
                                      blurRadius: 34,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.12),
                                    width: 1.1,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: _confirmSignOut,
                                  splashColor: Colors.white.withOpacity(.12),
                                  highlightColor: Colors.white.withOpacity(.06),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.logout_rounded,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Sign Out',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: .4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ), // end Column
                    ), // end Padding
                  ]), // end SliverChildListDelegate list
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
