import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../controllers/game_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/sudoku_board.dart';
import '_timer_widget.dart';
import 'game_review_screen.dart'; // Added for game review

// Import the new modular components
import '../components/components.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/game';
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  bool _played = false;
  late final AnimationController _intro; // intro animation
  bool _processedOutcome = false; // add near other state
  bool _savingStats = false; // NEW: show loading overlay while writing stats
  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 6));
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);

    // Trigger confetti once on win
    if (controller.isWin && !_played) {
      _played = true;
      _confetti.play();
    }

    Future<void> showResultOverlay() async {
      // Record stats once when outcome determined
      final profileController = context.read<ProfileController>();

      // Only proceed if stats haven't been recorded yet
      if ((controller.isWin || controller.isLoss) &&
          !controller.statsRecorded) {
        final level = controller.boardSize == 4
            ? 'easy'
            : controller.boardSize == 6
            ? 'medium'
            : 'hard';
        final seconds = controller.elapsed.inSeconds;
        final win = controller.isWin;
        final int ratingDelta;
        if (level == 'easy') {
          ratingDelta = win ? 5 : -5;
        } else if (level == 'medium') {
          ratingDelta = win ? 20 : -7;
        } else {
          ratingDelta = win ? 40 : -12;
        }
        try {
          if (!win)
            setState(() => _savingStats = true); // show overlay only on loss
          final result = await profileController.recordGame(
            level: level,
            win: win,
            seconds: seconds,
            ratingDelta: ratingDelta,
          );
          controller.lastOldRating = result['old'];
          controller.lastNewRating = result['new'];
          controller.lastDelta = result['delta'];
          setState(() {});
        } catch (e, st) {
          debugPrint('recordGame failed: $e');
          debugPrint('$st');
        } finally {
          if (!win && mounted)
            setState(
              () => _savingStats = false,
            ); // hide overlay only if it was shown
          controller.statsRecorded = true; // mark attempted to avoid loop
        }
      }
      // Show result dialog immediately when game ends
      if (!controller.resultDialogShown &&
          (controller.isWin || controller.isLoss)) {
        controller.resultDialogShown = true;
        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'result',
          barrierColor: Colors.black.withOpacity(0.55),
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
          transitionBuilder: (ctx, anim, __, ___) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            final scale = 0.85 + 0.15 * curved.value;
            final opacity = curved.value;
            final isWin = controller.isWin;
            final lossReason = controller.lossReason;
            String title;
            String subtitle;
            IconData icon;
            Color accent;
            if (isWin) {
              title = 'PUZZLE SOLVED';
              subtitle =
                  'Brilliant! You conquered a ${controller.boardSize}×${controller.boardSize} grid';
              icon = Icons.emoji_events_rounded;
              accent = const Color(0xFF06D4A0);
            } else {
              if (lossReason == LossReason.mistakes) {
                title = 'MISTAKE LIMIT REACHED';
                subtitle = 'Too many conflicts. Refocus and try again.';
                icon = Icons.warning_amber_rounded;
                accent = const Color(0xFFFF5D5D);
              } else {
                title = 'TIME UP';
                subtitle = 'The clock ran out. Keep pushing!';
                icon = Icons.timer_off_rounded;
                accent = const Color(0xFFFF8A3C);
              }
            }
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: ResultGlassCard(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                    accent: accent,
                    oldRating: controller.lastOldRating,
                    newRating: controller.lastNewRating,
                    delta: controller.lastDelta,
                    isWin: isWin,
                    puzzle: isWin ? null : controller.puzzle,
                    onNewGame: () {
                      Navigator.of(ctx).pop();
                      controller.newGame(size: controller.boardSize);
                      setState(() {
                        _processedOutcome = false;
                      });
                    },
                    onHome: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(ctx).pop();
                    },
                    onReviewPressed: !isWin
                        ? () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GameReviewScreen(
                                  puzzle: controller.puzzle,
                                  boardSize: controller.boardSize,
                                  oldRating: controller.lastOldRating,
                                  newRating: controller.lastNewRating,
                                  delta: controller.lastDelta,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ),
            );
          },
        );
      }
    }

    // Remove previous unconditional scheduling and replace with guarded trigger
    if ((controller.isWin || controller.isLoss) && !_processedOutcome) {
      _processedOutcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => showResultOverlay());
    }

    Future<bool> onWillPop() async {
      return await _confirmDialog(
            context,
            title: 'Leave Game?',
            message: 'Progress will be lost.',
            primary: 'Stay',
            secondary: 'Leave',
            secondaryColor: const Color(0xFF3B82F6), // changed to blue
            icon: Icons.exit_to_app_rounded,
          ) ??
          false;
    }

    void onReset() async {
      final ok = await _confirmDialog(
        context,
        title: 'Reset Puzzle?',
        message:
            'Start this ${controller.boardSize}×${controller.boardSize} grid again?',
        primary: 'Cancel',
        secondary: 'Reset',
        secondaryColor: Colors.redAccent, // changed to red
        icon: Icons.refresh_rounded,
      );
      if (ok ?? false) {
        controller.newGame(size: controller.boardSize);
        _played = false;
      }
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            const _AnimatedBackgroundGame(),
            // Moved SafeArea content below confetti so confetti renders on top
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Top bar intro
                    AnimatedBuilder(
                      animation: _intro,
                      child: GlassBar(
                        child: Row(
                          children: [
                            GlassIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () async {
                                if (await onWillPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            Expanded(child: Center(child: const TimerWidget())),
                            const SizedBox(width: 8),
                            _ResetButton(onTap: onReset),
                          ],
                        ),
                      ),
                      builder: (context, child) {
                        final raw = CurvedAnimation(
                          parent: _intro,
                          curve: const Interval(
                            0.05,
                            0.30,
                            curve: Curves.easeOutBack,
                          ),
                        ).value;
                        final v = raw.clamp(0.0, 1.0);
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, (1 - v) * -20),
                            child: child,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    // Mistake counter intro
                    AnimatedBuilder(
                      animation: _intro,
                      child: const MistakeCounter(),
                      builder: (context, child) {
                        final raw = CurvedAnimation(
                          parent: _intro,
                          curve: const Interval(
                            0.12,
                            0.40,
                            curve: Curves.easeOutBack,
                          ),
                        ).value;
                        final v = raw.clamp(0.0, 1.0);
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, (1 - v) * -14),
                            child: child,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Difficulty + progress bar intro (slide from left, reveal width)
                    AnimatedBuilder(
                      animation: _intro,
                      builder: (context, _) {
                        final raw = CurvedAnimation(
                          parent: _intro,
                          curve: const Interval(
                            0.22,
                            0.55,
                            curve: Curves.easeOutCubic,
                          ),
                        ).value;
                        final v = raw.clamp(0.0, 1.0);
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset((1 - v) * -70, 0),
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: v,
                                child: _ProgressDifficultyBar(
                                  controller: controller,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    // Board intro (scale + rise)
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _intro,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: BoardGlass(
                              progress: controller.completionPercent,
                              child: SudokuBoard(),
                            ),
                          ),
                        ),
                        builder: (context, child) {
                          final raw = CurvedAnimation(
                            parent: _intro,
                            curve: const Interval(
                              0.35,
                              0.80,
                              curve: Curves.easeOutBack,
                            ),
                          ).value;
                          final v = raw.clamp(0.0, 1.0);
                          final scale = 0.90 + 0.10 * v;
                          return Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, (1 - v) * 30),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.center,
                                child: child,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Number pad intro (slide up)
                    AnimatedBuilder(
                      animation: _intro,
                      child: _NumberPad(controller: controller),
                      builder: (context, child) {
                        final raw = CurvedAnimation(
                          parent: _intro,
                          curve: const Interval(
                            0.55,
                            0.95,
                            curve: Curves.easeOutBack,
                          ),
                        ).value;
                        final v = raw.clamp(0.0, 1.0);
                        final scale = 0.95 + 0.05 * v;
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, (1 - v) * 60),
                            child: Transform.scale(
                              scale: scale,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Confetti overlay (bottom blast upward) moved to top layer
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  children: [
                    // Center bottom main cannon
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConfettiWidget(
                        confettiController: _confetti,
                        blastDirection: -math.pi / 2,
                        blastDirectionality: BlastDirectionality.directional,
                        emissionFrequency: 0.0,
                        numberOfParticles: 65,
                        maxBlastForce: 70, // higher launch
                        minBlastForce: 35,
                        gravity: 0.12, // lower gravity so they reach top
                        particleDrag: 0.06,
                        minimumSize: const Size(6, 6),
                        maximumSize: const Size(16, 14),
                        shouldLoop: false,
                        colors: const [
                          Color(0xFF6366F1),
                          Color(0xFF0EA5E9),
                          Color(0xFF10B981),
                          Color(0xFFF59E0B),
                          Color(0xFFEF4444),
                        ],
                        createParticlePath: _starPath,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ConfettiWidget(
                        confettiController: _confetti,
                        blastDirection: -math.pi / 2 + 0.32,
                        blastDirectionality: BlastDirectionality.directional,
                        emissionFrequency: 0.0,
                        numberOfParticles: 42,
                        maxBlastForce: 55,
                        minBlastForce: 28,
                        gravity: 0.14,
                        particleDrag: 0.05,
                        minimumSize: const Size(6, 6),
                        maximumSize: const Size(14, 12),
                        shouldLoop: false,
                        colors: const [
                          Color(0xFF6366F1),
                          Color(0xFF0EA5E9),
                          Color(0xFF10B981),
                          Color(0xFFF59E0B),
                          Color(0xFFEF4444),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ConfettiWidget(
                        confettiController: _confetti,
                        blastDirection: -math.pi / 2 - 0.32,
                        blastDirectionality: BlastDirectionality.directional,
                        emissionFrequency: 0.0,
                        numberOfParticles: 42,
                        maxBlastForce: 55,
                        minBlastForce: 28,
                        gravity: 0.14,
                        particleDrag: 0.05,
                        minimumSize: const Size(6, 6),
                        maximumSize: const Size(14, 12),
                        shouldLoop: false,
                        colors: const [
                          Color(0xFF6366F1),
                          Color(0xFF0EA5E9),
                          Color(0xFF10B981),
                          Color(0xFFF59E0B),
                          Color(0xFFEF4444),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_savingStats)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.65),
                  child: Center(
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Lottie.asset(
                        'assets/lottie/loading.json',
                        repeat: true,
                        frameRate: FrameRate.max,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String primary,
  required String secondary,
  required Color secondaryColor,
  required IconData icon,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'confirm',
    barrierColor: Colors.black.withOpacity(0.55),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, __, ___) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      final y = (1 - curved.value) * 40;
      return Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, y),
          child: Center(
            child: _GlassConfirm(
              title: title,
              message: message,
              primary: primary,
              secondary: secondary,
              secondaryColor: secondaryColor,
              icon: icon,
              onClose: (res) => Navigator.of(ctx).pop(res),
            ),
          ),
        ),
      );
    },
  );
}

// ResultGlassCard was moved to lib/src/components/game/result_glass_card.dart

// RatingChangePill was moved to lib/src/components/game/rating_change_pill.dart

class _GlassConfirm extends StatelessWidget {
  final String title;
  final String message;
  final String primary;
  final String secondary;
  final Color secondaryColor;
  final IconData icon;
  final void Function(bool) onClose;
  const _GlassConfirm({
    required this.title,
    required this.message,
    required this.primary,
    required this.secondary,
    required this.secondaryColor,
    required this.icon,
    required this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    return GlassShell(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 40,
          minWidth: 250,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // dynamic gradient based on secondaryColor (so reset shows red, back shows blue)
                gradient: LinearGradient(
                  colors: [
                    secondaryColor.withOpacity(0.95),
                    secondaryColor.withOpacity(0.60),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.55),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 20,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.35,
                color: Colors.white.withOpacity(0.80),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: primary,
                    icon: Icons.close_rounded,
                    onTap: () => onClose(false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    label: secondary,
                    icon: Icons.check_rounded,
                    color1: secondaryColor,
                    onTap: () => onClose(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// GlassBar was moved to lib/src/components/common/glass_bar.dart

// GlassShell was moved to lib/src/components/common/glass_shell.dart

// BoardGlass was moved to lib/src/components/game/board_glass.dart

// ButtonBase was moved to lib/src/components/common/button_base.dart

// GradientButton was moved to lib/src/components/common/gradient_button.dart

// GlassButton was moved to lib/src/components/common/glass_button.dart

class _DifficultyPill extends StatelessWidget {
  final String label;
  final List<Color> colors;
  const _DifficultyPill({required this.label, required this.colors});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            colors.first.withOpacity(0.95),
            colors.last.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(.60),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.08),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.28), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  final String label;
  final List<Color> colors;
  const _ProgressBar({
    required this.percent,
    required this.label,
    required this.colors,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final fillWidth = (w * percent).clamp(0.0, w);
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                height: 46,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(.18),
                    width: 1.2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(.24),
                      Colors.white.withOpacity(.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(.05),
                      blurRadius: 14,
                      spreadRadius: -4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: fillWidth,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.first.withOpacity(.95),
                      colors.last.withOpacity(.95),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withOpacity(.60),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(.10),
                      blurRadius: 18,
                      spreadRadius: -6,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(.30),
                    width: 1.2,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white,
                      decoration: TextDecoration.none,
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

class _NumberPad extends StatelessWidget {
  final GameController controller;
  const _NumberPad({required this.controller});
  @override
  Widget build(BuildContext context) {
    final size = controller.boardSize;
    // Reduced font sizes to shrink keypad
    final fontSize = size == 4 ? 26.0 : (size == 6 ? 22.0 : 20.0);
    final aspect = size <= 6 ? 1.25 : 1.20; // makes cells a bit shorter
    return GlassBar(
      child: GridView.count(
        crossAxisCount: size <= 6 ? 4 : 5,
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: aspect,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...List.generate(size, (i) {
            final val = i + 1;
            return _PadButton(
              label: '$val',
              onTap: controller.isWin || controller.isLoss
                  ? null
                  : () => controller.setValue(val),
              color: Colors.blueAccent,
              fontSize: fontSize,
              disabled: controller.isWin || controller.isLoss,
            );
          }),
          _PadButton(
            label: '',
            icon: Icons.backspace_rounded,
            onTap: controller.isWin || controller.isLoss
                ? null
                : controller.clearCell,
            disabled: controller.isWin || controller.isLoss,
            color: Colors.redAccent,
            fontSize: fontSize * 0.85,
          ),
        ],
      ),
    );
  }
}

class _PadButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final double fontSize;
  final bool disabled;
  const _PadButton({
    required this.label,
    this.icon,
    required this.onTap,
    required this.color,
    required this.fontSize,
    this.disabled = false,
  });
  @override
  State<_PadButton> createState() => _PadButtonState();
}

class _PadButtonState extends State<_PadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 260),
  );
  void _activate() {
    // Don't do anything if disabled or onTap is null
    if (widget.disabled || widget.onTap == null) return;

    if (_ctrl.isAnimating) _ctrl.stop();
    _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disabled ? null : _activate,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value; // 0->1
          final scale = 1 - 0.10 * t;
          final blur = 26 - 10 * t;
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18 - 2 * t),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30 - 0.10 * t),
                  width: 1.3,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.35 - 0.20 * t),
                    Colors.white.withOpacity(0.12 + 0.05 * (1 - t)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.75 - 0.45 * t),
                    blurRadius: blur,
                    offset: Offset(0, 10 - 5 * t),
                    spreadRadius: 2 - 2 * t,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(.10),
                    blurRadius: 18,
                    spreadRadius: -6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Opacity(
                opacity: widget.disabled ? 0.4 : (1 - 0.10 * t),
                child: Center(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          color: widget.color.withOpacity(0.95 - 0.25 * t),
                          size: widget.fontSize * 0.9,
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(
                                    0.95 - 0.15 * t,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.fontSize,
                                ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Path _starPath(Size size) {
  // Create 5-point star path
  final path = Path();
  const points = 5;
  final outerRadius = size.width / 2;
  final innerRadius = outerRadius / 2.5;
  final center = Offset(size.width / 2, size.height / 2);
  for (int i = 0; i < points * 2; i++) {
    final isOuter = i.isEven;
    final angle = (math.pi / points) * i;
    final radius = isOuter ? outerRadius : innerRadius;
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

class _AnimatedBackgroundGame extends StatefulWidget {
  const _AnimatedBackgroundGame();
  @override
  State<_AnimatedBackgroundGame> createState() =>
      _AnimatedBackgroundGameState();
}

class _AnimatedBackgroundGameState extends State<_AnimatedBackgroundGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _GameGlowPainter(progress: _controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _GameGlowPainter extends CustomPainter {
  final double progress;
  _GameGlowPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 160);
    final c1 = Offset(
      size.width * (0.30 + 0.05 * (progress - 0.5)),
      size.height * 0.28,
    );
    final c2 = Offset(
      size.width * (0.75 + 0.05 * (0.5 - progress)),
      size.height * 0.65,
    );
    paint.color = const Color(0xFF06B6D4).withOpacity(0.40);
    canvas.drawCircle(c1, size.width * 0.55, paint);
    paint.color = const Color(0xFF6366F1).withOpacity(0.35);
    canvas.drawCircle(c2, size.width * 0.60, paint);
  }

  @override
  bool shouldRepaint(covariant _GameGlowPainter oldDelegate) => true;
}

// GlassIconButton was moved to lib/src/components/common/glass_icon_button.dart

class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4D4F), Color(0xFFDC2626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withOpacity(.60),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(.10),
              blurRadius: 14,
              spreadRadius: -6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(.28), width: 1.2),
        ),
        child: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}

class _ProgressDifficultyBar extends StatelessWidget {
  final GameController controller;
  const _ProgressDifficultyBar({required this.controller});
  String get _difficultyLabel {
    switch (controller.boardSize) {
      case 4:
        return 'EASY';
      case 6:
        return 'MEDIUM';
      default:
        return 'HARD';
    }
  }

  List<Color> get _difficultyColors {
    switch (controller.boardSize) {
      case 4:
        return const [Color(0xFF10B981), Color(0xFF059669)];
      case 6:
        return const [Color(0xFFF59E0B), Color(0xFFEA580C)];
      default:
        return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = controller.completionPercent;
    final pctLabel = '${(percent * 100).clamp(0, 100).toStringAsFixed(0)}%';
    final colors = _difficultyColors;
    return Row(
      children: [
        _DifficultyPill(label: _difficultyLabel, colors: colors),
        const SizedBox(width: 14),
        Expanded(
          child: _ProgressBar(
            percent: percent,
            label: pctLabel,
            colors: colors,
          ),
        ),
      ],
    );
  }
}
