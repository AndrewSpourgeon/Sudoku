import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';

class Cell extends StatelessWidget {
  final int row;
  final int col;
  const Cell({super.key, required this.row, required this.col});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final value = controller.puzzle.getValue(row, col);
    final isSelected =
        controller.selectedRow == row && controller.selectedCol == col;
    final isFixed = controller.puzzle.isFixed(row, col);
    final size = controller.boardSize;
    final boxRows = controller.puzzle.boxRows;
    final boxCols = controller.puzzle.boxCols;

    final bg = isSelected
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.14)
        : Colors.transparent;

    double fontScale;
    if (size == 4) {
      fontScale = 1.4;
    } else if (size == 6) {
      fontScale = 1.2;
    } else {
      fontScale = 1.0;
    }

    Color numberColor;
    if (isFixed) {
      numberColor = Colors.pinkAccent;
    } else if (value != 0) {
      numberColor = Colors.deepPurple.shade900;
    } else {
      numberColor = Theme.of(context).colorScheme.primary.withOpacity(0.9);
    }

    // Dynamic margins for subgrid borders
    bool leftThick = col % boxCols == 0;
    bool rightThick = (col + 1) % boxCols == 0;
    bool topThick = row % boxRows == 0;
    bool bottomThick = (row + 1) % boxRows == 0;

    return Container(
      margin: EdgeInsets.only(
        left: leftThick ? 2 : 1,
        right: rightThick ? 2 : 1,
        top: topThick ? 2 : 1,
        bottom: bottomThick ? 2 : 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : '$value',
          style: TextStyle(
            fontSize: 18 * fontScale,
            fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
            color: numberColor,
            letterSpacing: 1.2,
            shadows: isFixed
                ? [Shadow(color: Colors.pink.shade100, blurRadius: 2)]
                : [Shadow(color: Colors.blue.shade100, blurRadius: 2)],
          ),
        ),
      ),
    );
  }
}
