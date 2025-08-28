import 'package:flutter/material.dart';

class GameModesInfoSheet extends StatefulWidget {
  const GameModesInfoSheet({super.key});
  @override
  State<GameModesInfoSheet> createState() => _GameModesInfoSheetState();
}

class _GameModesInfoSheetState extends State<GameModesInfoSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final v = curved.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 60),
            child: _SheetBody(animationValue: v),
          ),
        );
      },
    );
  }
}

class _SheetBody extends StatelessWidget {
  final double animationValue;
  const _SheetBody({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyleTitle = theme.textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final textStyleBody = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white70,
      height: 1.3,
      letterSpacing: 0.25,
      fontWeight: FontWeight.w500,
    );

    Widget modeTile({
      required IconData icon,
      required String label,
      required List<Color> colors,
      required String details,
      required String rating,
      required String time,
      required String mistakes,
    }) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.first.withOpacity(.28),
              colors.last.withOpacity(.18),
              Colors.black.withOpacity(.40),
            ],
            stops: const [0, .55, 1],
          ),
          border: Border.all(color: Colors.white.withOpacity(.12), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(.55),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.65),
              blurRadius: 28,
              offset: const Offset(0, 28),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withOpacity(.55),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: textStyleTitle),
                  const SizedBox(height: 6),
                  Text(details, style: textStyleBody),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.star_border_rounded, label: rating),
                      _InfoChip(icon: Icons.timer_rounded, label: time),
                      _InfoChip(icon: Icons.clear_rounded, label: mistakes),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E2640),
                      Color(0xFF101726),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(.10),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.70),
                      blurRadius: 40,
                      offset: const Offset(0, 28),
                    ),
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(.25),
                      blurRadius: 60,
                      spreadRadius: -10,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 30),
                // Constrain overall height and make body scrollable to avoid overflow
                constraints: BoxConstraints(
                  // Cap height to 88% of screen so it never exceeds viewport
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(.55),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.info_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Game Modes & Rules',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    // Move all variable-height content into scroll view
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            modeTile(
                              icon: Icons.auto_awesome_rounded,
                              label: 'Easy',
                              colors: const [
                                Color(0xFF34D399),
                                Color(0xFF059669),
                              ],
                              details:
                                  '4×4 board. Great for quick warm‑ups and learning patterns.',
                              rating: '+5 / -5 rating',
                              time: 'Time limit: 1m 30s', // updated from 5 min
                              mistakes: 'Mistake limit: 1', // updated from 5
                            ),
                            const SizedBox(height: 18),
                            modeTile(
                              icon: Icons.grid_view_rounded,
                              label: 'Medium',
                              colors: const [
                                Color(0xFFFBBF24),
                                Color(0xFFF97316),
                              ],
                              details:
                                  '6×6 board. Balanced challenge with moderate deduction.',
                              rating: '+20 / -7 rating',
                              time: 'Time limit: 5 min', // updated from 10 min
                              mistakes: 'Mistake limit: 4',
                            ),
                            const SizedBox(height: 18),
                            modeTile(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Hard',
                              colors: const [
                                Color(0xFFFB7185),
                                Color(0xFFE11D48),
                              ],
                              details:
                                  '9×9 board. Full classic depth—accuracy & speed both matter.',
                              rating: '+40 / -12 rating',
                              time: 'Time limit: 15 min',
                              mistakes: 'Mistake limit: 5', // updated from 3
                            ),
                            const SizedBox(height: 26),
                            Text(
                              'Scoring Notes',
                              style: textStyleTitle?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rating changes apply when a game ends. Both running out of time and reaching the mistake limit count as a loss.',
                              style: textStyleBody,
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                'Tap a difficulty to begin your next puzzle!',
                                style: textStyleBody?.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              'How to Play Sudoku',
                              style: textStyleTitle?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            _Bullet(
                              text:
                                  'Fill the grid so every row, column, and outlined box contains each number exactly once.',
                            ),
                            _Bullet(
                              text:
                                  'Tap a cell, then tap a number to place it. Tap again to clear or change.',
                            ),
                            _Bullet(
                              text:
                                  'Avoid duplicate numbers in the same row, column, or box—those count as mistakes.',
                            ),
                            _Bullet(
                              text:
                                  'Use logic, not guessing. Start with numbers that appear most or rows/columns nearly complete.',
                            ),
                            _Bullet(
                              text:
                                  'If you reach the mistake limit or the timer hits zero, the game is a loss.',
                            ),
                            _Bullet(
                              text:
                                  'Win by completing the entire board correctly before time runs out.',
                            ),
                            const SizedBox(height: 30),
                          ],
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
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                height: 1.25,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
