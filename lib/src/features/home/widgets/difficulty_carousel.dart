import 'package:flutter/material.dart';
import '../models/difficulty_option.dart';
import 'difficulty_card.dart';

class DifficultyCarousel extends StatelessWidget {
  final void Function(int size) onSelect;
  const DifficultyCarousel({super.key, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final items = [
      const DifficultyOption(
        label: 'Easy',
        size: 4,
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        icon: Icons.auto_awesome_rounded,
      ),
      const DifficultyOption(
        label: 'Medium',
        size: 6,
        colors: [Color(0xFFFBBF24), Color(0xFFF97316)],
        icon: Icons.grid_view_rounded,
      ),
      const DifficultyOption(
        label: 'Hard',
        size: 9,
        colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
        icon: Icons.local_fire_department_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final cardWidth = (constraints.maxWidth - gap * 2) / 3;
        return Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              SizedBox(
                width: cardWidth,
                child: DifficultyCard(
                  option: items[i],
                  onTap: () => onSelect(items[i].size),
                  index: i,
                ),
              ),
              if (i != items.length - 1) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}
