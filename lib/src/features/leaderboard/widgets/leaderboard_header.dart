import 'package:flutter/material.dart';

class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.1),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.26),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 30,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: const [
            SizedBox(width: 44, child: Text('#', style: _hdrStyle)),
            SizedBox(width: 12),
            Expanded(flex: 3, child: Text('Player', style: _hdrStyle)),
            Expanded(
              flex: 2,
              child: Text(
                'Rating',
                style: _hdrStyle,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: Text(
                'Win %',
                style: _hdrStyle,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

const _hdrStyle = TextStyle(
  color: Colors.white70,
  fontSize: 12,
  letterSpacing: 1.1,
  fontWeight: FontWeight.w600,
);
