import 'package:flutter/material.dart';
import '../../../models/leaderboard_entry.dart';

/// Displays a player avatar with a rank label in the bottom right corner
class PlayerAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool highlight;
  final double size;

  const PlayerAvatar({
    super.key,
    required this.entry,
    required this.rank,
    this.highlight = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final accent = switch (rank) {
      1 => const Color(0xFFFFD700), // Gold
      2 => const Color(0xFFC0C0C0), // Silver
      3 => const Color(0xFFCD7F32), // Bronze
      _ =>
        highlight
            ? const Color(0xFF06B6D4) // Cyan for the current user
            : Colors.white.withOpacity(0.8), // White for others
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accent.withOpacity(.18), accent.withOpacity(.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withOpacity(.65), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(.35),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size),
            child: entry.photoUrl != null && entry.photoUrl!.isNotEmpty
                ? Image.network(
                    entry.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitials(),
                  )
                : _buildInitials(),
          ),
        ),
        // Rank badge
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials() {
    final name = entry.displayName ?? 'Player';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Container(
      alignment: Alignment.center,
      color: Colors.black38,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size / 2,
        ),
      ),
    );
  }
}
