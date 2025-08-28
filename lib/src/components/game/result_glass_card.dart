import 'package:flutter/material.dart';
import '../../models/sudoku_puzzle.dart';
import '../common/glass_shell.dart';
import '../common/glass_button.dart';
import 'rating_change_pill.dart';

class ResultGlassCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final int? oldRating;
  final int? newRating;
  final int? delta;
  final bool isWin;
  final VoidCallback onNewGame;
  final VoidCallback onHome;
  final SudokuPuzzle? puzzle;
  final VoidCallback? onReviewPressed;

  const ResultGlassCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.oldRating,
    this.newRating,
    this.delta,
    required this.isWin,
    required this.onNewGame,
    required this.onHome,
    this.puzzle,
    this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassShell(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 40,
          minWidth: 260,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.85), accent.withOpacity(0.45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.55),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 22,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.35,
                color: Colors.white.withOpacity(0.82),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            // Rating change display
            if (delta != null && newRating != null && oldRating != null) ...[
              const SizedBox(height: 4),
              RatingChangePill(
                oldRating: oldRating!,
                newRating: newRating!,
                delta: delta!,
                isWin: isWin,
              ),
            ],
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    onTap: onHome,
                    customDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEAB308).withOpacity(0.55),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(.10),
                          blurRadius: 14,
                          spreadRadius: -6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _GradientButton(
                    label: 'New Game',
                    icon: Icons.play_arrow_rounded,
                    onTap: onNewGame,
                  ),
                ),
              ],
            ),
            // Add Review button if onReviewPressed callback is provided
            if (onReviewPressed != null && !isWin) ...[
              const SizedBox(height: 16),
              GlassButton(
                label: 'Review Game',
                icon: Icons.autorenew_rounded,
                onTap: onReviewPressed!,
                // Blue gradient for the review button
                customDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const defaultColor = Color(0xFF10B981);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: defaultColor.withOpacity(.55),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
