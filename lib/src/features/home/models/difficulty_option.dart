import 'package:flutter/material.dart';

class DifficultyOption {
  final String label;
  final int size;
  final List<Color> colors;
  final IconData icon;
  const DifficultyOption({
    required this.label,
    required this.size,
    required this.colors,
    required this.icon,
  });
}
