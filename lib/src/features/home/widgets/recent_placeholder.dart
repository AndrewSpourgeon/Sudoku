import 'package:flutter/material.dart';

class RecentPlaceholder extends StatelessWidget {
  const RecentPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Icon(
        Icons.hourglass_empty_rounded,
        color: Colors.white24,
        size: 36,
      ),
    );
  }
}
