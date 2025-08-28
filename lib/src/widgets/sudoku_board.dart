import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import 'cell.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final puzzle = controller.puzzle;
    final size = puzzle.size;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F7FA), Color(0xFFE3E6F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.biggest;
          return Stack(
            children: [
              CustomPaint(
                size: boardSize,
                painter: _DynamicGridPainter(
                  n: puzzle.size,
                  boxRows: puzzle.boxRows,
                  boxCols: puzzle.boxCols,
                ),
              ),
              Column(
                children: List.generate(size, (r) {
                  return Expanded(
                    child: Row(
                      children: List.generate(size, (c) {
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              boxShadow: [
                                if (controller.selectedRow == r &&
                                    controller.selectedCol == c)
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.25),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => controller.selectCell(r, c),
                              child: Cell(row: r, col: c),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DynamicGridPainter extends CustomPainter {
  final int n;
  final int boxRows;
  final int boxCols;
  _DynamicGridPainter({
    required this.n,
    required this.boxRows,
    required this.boxCols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintThin = Paint()
      ..color = Colors.blueGrey.shade400
      ..strokeWidth = 1.0
      ..isAntiAlias = false;
    final paintThick = Paint()
      ..color = Colors.blueGrey.shade900
      ..strokeWidth = 2.2
      ..isAntiAlias = false;

    final cellSize = size.width / n;

    // Vertical lines
    for (int i = 0; i <= n; i++) {
      final thick = (i % boxCols == 0) || i == n;
      final p = thick ? paintThick : paintThin;
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, cellSize * n), p);
    }
    // Horizontal lines
    for (int i = 0; i <= n; i++) {
      final thick = (i % boxRows == 0) || i == n;
      final p = thick ? paintThick : paintThin;
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(cellSize * n, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicGridPainter old) =>
      old.n != n || old.boxRows != boxRows || old.boxCols != boxCols;
}
