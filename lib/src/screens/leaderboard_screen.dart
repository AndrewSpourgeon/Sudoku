import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';

import '../models/leaderboard_entry.dart';
import '../repositories/user_repository.dart';
import '../controllers/profile_controller.dart';
import '../features/leaderboard/widgets/nebula_background.dart';
import '../features/leaderboard/widgets/rank_progress_capsule.dart';
import '../features/leaderboard/widgets/leaderboard_row.dart';
import '../features/leaderboard/widgets/leaderboard_header.dart';
import '../features/leaderboard/widgets/profile_share_card.dart';
import '../features/leaderboard/widgets/leaderboard_particles.dart';
import '../features/leaderboard/widgets/top3_podium.dart';

class LeaderboardScreen extends StatefulWidget {
  static const routeName = '/leaderboard';
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();
  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _progressRowAnim = CurvedAnimation(
    parent: _introController,
    curve: const Interval(0.32, 0.72, curve: Curves.easeOutCubic),
  );
  late final Stream<List<LeaderboardEntry>> _stream;
  final GlobalKey<_LeaderboardListState> _listKey =
      GlobalKey<_LeaderboardListState>();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _stream = UserRepository().leaderboardStream(limit: 100);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _introController.forward(),
    );
  }

  Future<void> _refreshLeaderboard() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      // Add a delay to show the loading animation
      await Future.delayed(const Duration(milliseconds: 2000));

      // The stream will automatically update with fresh data from Firestore
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final myRank = profileController.rank;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => Stack(
              children: [
                NebulaBackground(animation: _controller),
                LeaderboardParticles(animation: _controller),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(.25),
                                          Colors.white.withOpacity(.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(.15),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ShaderMask(
                                          shaderCallback: (rect) =>
                                              const LinearGradient(
                                                colors: [
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFFBAE6FD),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ).createShader(rect),
                                          blendMode: BlendMode.srcIn,
                                          child: const Text(
                                            'Global Leaderboard',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _refreshLeaderboard();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: _isRefreshing
                                                  ? [
                                                      const Color(0xFF8B5CF6),
                                                      const Color(0xFF6366F1),
                                                    ]
                                                  : [
                                                      const Color(0xFF10B981),
                                                      const Color(0xFF059669),
                                                    ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (_isRefreshing
                                                            ? const Color(
                                                                0xFF8B5CF6,
                                                              )
                                                            : const Color(
                                                                0xFF10B981,
                                                              ))
                                                        .withOpacity(.4),
                                                blurRadius: _isRefreshing
                                                    ? 24
                                                    : 20,
                                                offset: const Offset(0, 8),
                                                spreadRadius: _isRefreshing
                                                    ? 3
                                                    : 2,
                                              ),
                                            ],
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                .25,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: _isRefreshing
                                              ? SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: Lottie.asset(
                                                    'assets/lottie/loading.json',
                                                    fit: BoxFit.contain,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (myRank != null) const SizedBox(height: 12),
                            if (myRank != null)
                              AnimatedBuilder(
                                animation: _progressRowAnim,
                                builder: (context, _) {
                                  final v = _progressRowAnim.value;
                                  return Opacity(
                                    opacity: (v.clamp(0.0, 1.0)).toDouble(),
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - v) * 24),
                                      child: LayoutBuilder(
                                        builder: (context, c) {
                                          return ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 680,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  child: RankProgressCapsule(
                                                    rank: myRank,
                                                    onShare: () =>
                                                        _shareProfileCard(
                                                          myRank,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: StreamBuilder<List<LeaderboardEntry>>(
                          stream: _stream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                            final data = snapshot.data ?? [];
                            if (data.isEmpty) {
                              return Center(
                                child: Text(
                                  'No players yet',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              );
                            }
                            return _LeaderboardList(
                              key: _listKey,
                              entries: data,
                              myUid: myUid,
                              intro: _introController,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  child: AnimatedBuilder(
                    animation: _introController,
                    builder: (context, _) {
                      final show =
                          _introController.value > 0.4 && myRank != null;
                      return IgnorePointer(
                        ignoring: !show,
                        child: Opacity(
                          opacity: show ? 1 : 0,
                          child: GestureDetector(
                            onTap: () {
                              final ok =
                                  _listKey.currentState?.scrollToMine() ??
                                  false;
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your rank is outside the loaded range',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF06B6D4).withOpacity(.85),
                                    const Color(0xFF6366F1).withOpacity(.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(.55),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(.30),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_pin_circle_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareProfileCard(int rank) async {
    // Create and show loading overlay
    late OverlayEntry loadingOverlay;
    loadingOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Lottie.asset(
                'assets/lottie/loading.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(loadingOverlay);

    try {
      final key = GlobalKey();
      final overlay = Overlay.of(context);
      final profileController = context.read<ProfileController>();
      final name = profileController.profile?.displayName ?? 'Player';
      final rating = profileController.globalRating;
      final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
      final bestRating = profileController.bestGlobalRating ?? rating;
      final fastest = profileController.fastestWinSeconds;
      final streak = profileController.currentStreak;
      final bestRank = profileController.bestRank ?? rank;
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => Positioned(
          left: -4000,
          top: -4000,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 1080,
              height: 1080,
              child: ProfileShareCard(
                rank: rank, // current live rank
                bestRank: bestRank,
                rating: rating,
                bestRating: bestRating,
                fastestSeconds: fastest,
                streakDays: streak,
                name: name,
                photoUrl: photoUrl,
              ),
            ),
          ),
        ),
      );
      overlay.insert(entry);
      await Future.delayed(const Duration(milliseconds: 60));
      final ctx = key.currentContext;
      final boundary = ctx?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        entry.remove();
        Share.share('I am currently #$rank on the Sudoku Global Leaderboard!');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sudoku_profile_rank_$rank.png');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            'I am currently #$rank on the Sudoku Global Leaderboard! Can you beat me?',
      );
      entry.remove();
      loadingOverlay.remove();
    } catch (e) {
      Share.share('I am currently #$rank on the Sudoku Global Leaderboard!');
      loadingOverlay.remove();
    }
  }
}

class _LeaderboardList extends StatefulWidget {
  final List<LeaderboardEntry> entries;
  final String? myUid;
  final AnimationController intro;
  const _LeaderboardList({
    super.key,
    required this.entries,
    required this.myUid,
    required this.intro,
  });
  @override
  State<_LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<_LeaderboardList> {
  late final ScrollController _scrollController = ScrollController();
  bool scrollToMine() {
    final uid = widget.myUid;
    if (uid == null) return false;
    if (!_scrollController.hasClients) return false;
    final index = widget.entries.indexWhere((e) => e.uid == uid);
    if (index == -1) return false;
    final target = index + 1;
    const estHeight = 78.0;
    final desired = (target - 0.5) * estHeight;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      desired.clamp(0, max),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final myUid = widget.myUid;
    final intro = widget.intro;
    final hasTop3 = entries.length >= 3;
    if (!hasTop3) {
      // Fallback to original behavior when fewer than 3 entries
      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AnimatedBuilder(
              animation: intro,
              builder: (context, _) {
                final v = CurvedAnimation(
                  parent: intro,
                  curve: const Interval(0.05, 0.28, curve: Curves.easeOutCubic),
                ).value;
                final scale = 0.94 + 0.06 * v;
                return Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * 36),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: const LeaderboardHeader(),
                    ),
                  ),
                );
              },
            );
          }
          final e = entries[index - 1];
          final rank = index;
          final highlight = e.uid == myUid;
          final intervalStart = 0.30 + (rank * 0.018);
          final intervalEnd = intervalStart + 0.40;
          return AnimatedBuilder(
            animation: intro,
            builder: (context, _) {
              final v = CurvedAnimation(
                parent: intro,
                curve: Interval(
                  intervalStart.clamp(0.0, 0.97),
                  intervalEnd.clamp(0.0, 1.0),
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
                    alignment: Alignment.center,
                    child: LeaderboardRow(
                      rank: rank,
                      entry: e,
                      highlight: highlight,
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // With top 3 podium: list = podium + header + remaining rows (from rank 4)
    final remainingCount = entries.length - 3; // can be 0
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: 2 + remainingCount, // podium + header + rest
      itemBuilder: (context, index) {
        if (index == 0) {
          // Podium
          return AnimatedBuilder(
            animation: intro,
            builder: (context, _) {
              final v = CurvedAnimation(
                parent: intro,
                curve: const Interval(0.02, 0.22, curve: Curves.easeOutCubic),
              ).value;
              final scale = 0.94 + 0.06 * v;
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, (1 - v) * 40),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Top3Podium(
                      first: entries[0],
                      second: entries[1],
                      third: entries[2],
                      myUid: myUid,
                    ),
                  ),
                ),
              );
            },
          );
        }
        if (index == 1) {
          // Header appears after podium
          return AnimatedBuilder(
            animation: intro,
            builder: (context, _) {
              final v = CurvedAnimation(
                parent: intro,
                curve: const Interval(0.18, 0.40, curve: Curves.easeOutCubic),
              ).value;
              final scale = 0.94 + 0.06 * v;
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, (1 - v) * 30),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: const LeaderboardHeader(),
                  ),
                ),
              );
            },
          );
        }
        // Remaining rows start at rank 4 (previously duplicated rank 3)
        final listIndex =
            index + 2; // index 2 => rank 4, index 3 => rank 5, ...
        final e = entries[listIndex - 1];
        final highlight = e.uid == myUid;
        final intervalStart = 0.32 + (listIndex * 0.018);
        final intervalEnd = intervalStart + 0.40;
        return AnimatedBuilder(
          animation: intro,
          builder: (context, _) {
            final v = CurvedAnimation(
              parent: intro,
              curve: Interval(
                intervalStart.clamp(0.0, 0.97),
                intervalEnd.clamp(0.0, 1.0),
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
                  alignment: Alignment.center,
                  child: LeaderboardRow(
                    rank: listIndex,
                    entry: e,
                    highlight: highlight,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
