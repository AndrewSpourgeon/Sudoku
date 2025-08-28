import 'package:flutter/material.dart';

class LeaderboardHint extends StatelessWidget {
  const LeaderboardHint({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: Colors.amber.shade300,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Play at least one game to appear on the global leaderboard.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
