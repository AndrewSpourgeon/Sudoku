import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';

class GameReviewScreen extends StatefulWidget {
  static const routeName = '/game-review';

  final SudokuPuzzle puzzle;
  final int boardSize;
  final int? oldRating;
  final int? newRating;
  final int? delta;

  const GameReviewScreen({
    super.key,
    required this.puzzle,
    required this.boardSize,
    this.oldRating,
    this.newRating,
    this.delta,
  });

  @override
  State<GameReviewScreen> createState() => _GameReviewScreenState();
}

class _GameReviewScreenState extends State<GameReviewScreen>
    with TickerProviderStateMixin {
  bool _showingSolution = false;
  late AnimationController _animController; // toggle animation
  late Animation<double> _animation; // toggle animation curve
  late AnimationController _introController; // page intro + subtle looping
  late Animation<double> _intro; // eased intro

  double _stagger(double start, double end) {
    final t = _intro.value;
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _introController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();
    _intro = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _toggleSolutionView() {
    setState(() {
      _showingSolution = !_showingSolution;
      if (_showingSolution) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background
            const _AnimatedBackgroundReview(),
            // Main content
            AnimatedBuilder(
              animation: _intro,
              builder: (context, _) {
                final h = _stagger(.00, .25);
                final title = _stagger(.10, .40);
                final rating = _stagger(.25, .55);
                final toggle = _stagger(.40, .65);
                final board = _stagger(.45, .85);
                final legend = _stagger(.70, 1.0);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Opacity(
                          opacity: h,
                          child: Transform.translate(
                            offset: Offset(0, (1 - h) * -20),
                            child: _buildHeader(),
                          ),
                        ),
                        // Decrease padding for 4x4 board to give more room to other elements
                        SizedBox(height: widget.boardSize == 4 ? 18 : 24),
                        Opacity(
                          opacity: title,
                          child: Transform.translate(
                            offset: Offset(0, (1 - title) * 30),
                            child: _buildTitle(),
                          ),
                        ),
                        // Adjust spacing based on board size
                        SizedBox(height: widget.boardSize == 4 ? 12 : 16),
                        if (widget.delta != null &&
                            widget.oldRating != null &&
                            widget.newRating != null)
                          Opacity(
                            opacity: rating,
                            child: Transform.translate(
                              offset: Offset(0, (1 - rating) * 30),
                              child: RatingDisplay(
                                delta: widget.delta!,
                                oldRating: widget.oldRating!,
                                newRating: widget.newRating!,
                              ),
                            ),
                          ),
                        // Further reduce height for 4x4 board
                        SizedBox(height: widget.boardSize == 4 ? 8 : 12),
                        Opacity(
                          opacity: toggle,
                          child: Transform.translate(
                            offset: Offset(0, (1 - toggle) * 30),
                            child: _buildToggleButton(),
                          ),
                        ),
                        // Adjust vertical spacing based on board size
                        SizedBox(height: widget.boardSize == 4 ? 14 : 20),
                        Opacity(
                          opacity: board,
                          child: Transform.scale(
                            // Optimize scale for different board sizes
                            scale: widget.boardSize == 4
                                ? (0.85 + 0.15 * board) // Smaller scale for 4x4
                                : (0.92 +
                                      0.08 *
                                          board), // Regular scale for larger boards
                            child: _buildPuzzleBoard(),
                          ),
                        ),
                        // Consistent spacing regardless of board size
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: legend,
                          child: Transform.translate(
                            offset: Offset(0, (1 - legend) * 40),
                            child: _buildLegend(),
                          ),
                        ),
                        // Consistent bottom padding
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Enhanced home button with subtle pulse animation
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween<double>(begin: 0.6, end: 1.0),
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3 * value),
                      blurRadius: 16 * value,
                      spreadRadius: 2 * value,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    gradient: LinearGradient(
                      colors: [
                        const Color(
                          0xFF3B82F6,
                        ).withOpacity(0.9), // Brighter blue
                        const Color(0xFF2563EB).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 18, // Slightly larger
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFEC4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(rect),
              blendMode: BlendMode.srcIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'GAME REVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildTitle() {
    final difficultyName = widget.boardSize == 4
        ? 'EASY'
        : widget.boardSize == 6
        ? 'MEDIUM'
        : 'HARD';

    final difficultyColors = widget.boardSize == 4
        ? [const Color(0xFF10B981), const Color(0xFF059669)] // Green for easy
        : widget.boardSize == 6
        ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)] // Blue for medium
        : [const Color(0xFFEF4444), const Color(0xFFDC2626)]; // Red for hard

    return _GlassContainer(
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: difficultyColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(rect),
            blendMode: BlendMode.srcIn,
            child: Text(
              '$difficultyName ${widget.boardSize}×${widget.boardSize}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 16,
                  color: const Color(0xFFE0F2FE), // Light blue
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    colors: [
                      const Color(0xFFE0F2FE), // Light blue
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(rect),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    'Compare your answers with the solution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: _toggleSolutionView,
      child: _GlassContainer(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: !_showingSolution
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(.85),
                              const Color(0xFF6366F1).withOpacity(.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _showingSolution
                        ? Colors.white.withOpacity(0.08)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: !_showingSolution
                        ? [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'YOUR ANSWERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: _showingSolution
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(.85),
                              const Color(0xFF0EA5E9).withOpacity(.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !_showingSolution
                        ? Colors.white.withOpacity(0.08)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _showingSolution
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(.45),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'SOLUTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPuzzleBoard() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final targetWidth = (screenWidth - 32); // padding already 16 each side
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Cap width for very wide screens, keep near original feel
              maxWidth: screenWidth < 600 ? targetWidth : 520,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: _GlassContainer(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 1 - _animation.value,
                        child: _SudokuBoardDisplay(
                          puzzle: widget.puzzle,
                          boardSize: widget.boardSize,
                          showingSolution: false,
                        ),
                      ),
                      Opacity(
                        opacity: _animation.value,
                        child: _SudokuBoardDisplay(
                          puzzle: widget.puzzle,
                          boardSize: widget.boardSize,
                          showingSolution: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    // Define legend items based on current mode
    final legendItems = [
      _LegendItem(color:const Color(0xFF4ADE80), label: 'Correct Answer'),
      _LegendItem(color: Colors.red.shade400, label: 'Wrong Answer'),
      _LegendItem(
        color: Colors.orange.shade300,
        label: 'Empty Cell',
        hasOutline: true,
      ),
      _LegendItem(color: Colors.grey.shade400, label: 'Given Clue'),
      if (_showingSolution)
        _LegendItem(color: const Color(0xFF10B981), label: 'Corrected Answer'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: legendItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: item,
              ),
            )
            .toList(),
      ),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  final int delta;
  final int oldRating;
  final int newRating;
  const RatingDisplay({
    super.key,
    required this.delta,
    required this.oldRating,
    required this.newRating,
  });
  @override
  Widget build(BuildContext context) {
    final gained = delta > 0;
    final neutral = delta == 0;
    final baseColors = neutral
        ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
        : gained
        ? [const Color(0xFF10B981), const Color(0xFF059669)]
        : [const Color(0xFFF87171), const Color(0xFFDC2626)];
    final icon = neutral
        ? Icons.horizontal_rule_rounded
        : gained
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    return _GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ), // tighter
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Old rating
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Color(0xFF94A3B8), Color(0xFFD1D5DB)],
            ).createShader(rect),
            blendMode: BlendMode.srcIn,
            child: Text(
              '$oldRating',
              style: const TextStyle(
                fontSize: 16, // smaller
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  baseColors.first.withOpacity(.95),
                  baseColors.last.withOpacity(.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColors.last.withOpacity(.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: gained
                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                  : (neutral
                        ? [Colors.white70, Colors.white]
                        : [const Color(0xFFF87171), const Color(0xFFFCA5A5)]),
            ).createShader(rect),
            blendMode: BlendMode.srcIn,
            child: Text(
              '$newRating',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: baseColors
                    .map((c) => c.withOpacity(gained ? .95 : .90))
                    .toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColors.last.withOpacity(.50),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(.25),
                width: 1,
              ),
            ),
            child: Text(
              gained
                  ? '+${delta.abs()}'
                  : (neutral ? '${delta.abs()}' : '-${delta.abs()}'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasOutline;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Larger, more visible indicator with enhanced glow
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: hasOutline ? Colors.transparent : color,
              shape: BoxShape.circle,
              border: hasOutline ? Border.all(color: color, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// (This class was removed as it's no longer used)

// Replace simple static background with animated version
class _AnimatedBackgroundReview extends StatefulWidget {
  const _AnimatedBackgroundReview();
  @override
  State<_AnimatedBackgroundReview> createState() =>
      _AnimatedBackgroundReviewState();
}

class _AnimatedBackgroundReviewState extends State<_AnimatedBackgroundReview>
    with SingleTickerProviderStateMixin {
  late AnimationController _bg;
  @override
  void initState() {
    super.initState();
    _bg = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bg,
      builder: (context, _) {
        final t = _bg.value;
        final shift = (math.sin(t * math.pi * 2) + 1) / 2; // 0..1
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    shift,
                  )!,
                  Color.lerp(
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                    shift,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120 + 40 * math.sin(t * 2 * math.pi),
                  right: -140 + 30 * math.cos(t * 2 * math.pi),
                  child: _glowOrb(const Color(0xFF6366F1), 340, 0.30),
                ),
                Positioned(
                  bottom: -110 + 35 * math.cos(t * 2 * math.pi),
                  left: -130 + 28 * math.sin(t * 2 * math.pi),
                  child: _glowOrb(const Color(0xFF10B981), 280, 0.25),
                ),
                Positioned(
                  top: 160 + 26 * math.sin(t * 2 * math.pi + 2.2),
                  left: 40 + 34 * math.cos(t * 2 * math.pi + 1.2),
                  child: _glowOrb(const Color(0xFF8B5CF6), 200, 0.22),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _glowOrb(Color color, double size, double opacity) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

class _SudokuBoardDisplay extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final int boardSize;
  final bool showingSolution;

  const _SudokuBoardDisplay({
    required this.puzzle,
    required this.boardSize,
    required this.showingSolution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Colors.white, // Changed to white background like in the game screen
      child: Column(
        children: List.generate(boardSize, (row) {
          return Expanded(
            child: Row(
              children: List.generate(boardSize, (col) {
                // Determine cell content and styling
                final isFixed = puzzle.isFixed(row, col);
                final userValue = puzzle.getValue(row, col);
                final solutionValue = puzzle.solution[row][col];
                final isEmpty = userValue == 0;
                final isCorrect = userValue == solutionValue;
                final displayValue = showingSolution
                    ? solutionValue
                    : userValue;

                // Cell borders - thicker for box boundaries
                final boxRows = puzzle.boxRows;
                final boxCols = puzzle.boxCols;
                final bool isRightBorder =
                    (col + 1) % boxCols == 0 && col < boardSize - 1;
                final bool isBottomBorder =
                    (row + 1) % boxRows == 0 && row < boardSize - 1;

                // Determine cell background color
                Color backgroundColor = Colors.white; // board stays white

                // Default text color
                Color textColor = Colors.black87;

                if (isFixed) {
                  // Given clues: white background, black numbers
                  backgroundColor = Colors.white;
                  textColor = Colors.black87;
                } else if (isEmpty) {
                  // Empty cells: clear yellow background
                  backgroundColor = const Color(0xFFFFF9C4); // light yellow
                  textColor = Colors.black87;
                } else if (isCorrect) {
                  // User provided a correct answer: keep cell white, show green number
                  backgroundColor = Colors.white;
                  textColor = const Color(0xFF10B981);
                } else {
                  // Wrong answer: keep cell white, show red number
                  backgroundColor = Colors.white;
                  textColor = Colors.red.shade700;
                }

                // Adjust colors when showing solution
                if (showingSolution) {
                  if (isFixed) {
                    // Fixed clues remain black on white
                    backgroundColor = Colors.white;
                    textColor = Colors.black87;
                  } else {
                    // Show the correct solution value. If user's answer was wrong, highlight with a green background
                    if (!isCorrect) {
                      backgroundColor = const Color(
                        0xFFD1FAE5,
                      ); // subtle filled green for corrected cells
                      textColor = const Color(
                        0xFF065F46,
                      ); // darker green for contrast
                    } else {
                      // If user's answer was already correct, keep white background and green text
                      backgroundColor = Colors.white;
                      textColor = const Color(0xFF10B981);
                    }
                  }
                }

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border(
                        right: BorderSide(
                          width: isRightBorder ? 1.5 : 0.5,
                          color: Colors.black.withOpacity(
                            isRightBorder ? 0.3 : 0.15,
                          ),
                        ),
                        bottom: BorderSide(
                          width: isBottomBorder ? 1.5 : 0.5,
                          color: Colors.black.withOpacity(
                            isBottomBorder ? 0.3 : 0.15,
                          ),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Show the cell value
                          if (displayValue != 0)
                            Text(
                              displayValue.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: boardSize <= 6
                                    ? 26
                                    : 20, // Slightly larger for better visibility
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          // When showing solution and there was a mistake, show a visual indicator
                          if (showingSolution &&
                              !isCorrect &&
                              !isEmpty &&
                              !isFixed)
                            Container(
                              height: boardSize <= 6 ? 34 : 28,
                              width: boardSize <= 6 ? 34 : 28,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(17),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: -1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
