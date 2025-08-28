import 'package:flutter/material.dart';

class ShareRankButton extends StatelessWidget {
  final VoidCallback onShare;
  final int rank;
  const ShareRankButton({super.key, required this.onShare, required this.rank});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShare,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(.32),
              Colors.white.withOpacity(.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(.28), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(.55),
              blurRadius: 30,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: const Icon(
          Icons.ios_share_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
