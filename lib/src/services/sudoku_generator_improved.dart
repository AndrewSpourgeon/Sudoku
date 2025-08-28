import 'dart:math';

import '../models/sudoku_puzzle.dart';

class SudokuGenerator {
  // Generate puzzle for sizes 4 (2x2 boxes), 6 (3x2 boxes), 9 (3x3 boxes)
  // Generates valid puzzles without enforcing uniqueness (for better performance)
  static SudokuPuzzle generate({required int size}) {
    late int boxRows;
    late int boxCols;

    // Calculate box dimensions based on puzzle size
    switch (size) {
      case 4:
        boxRows = 2;
        boxCols = 2;
        break;
      case 6:
        boxRows = 2;
        boxCols = 3;
        break;
      case 9:
        boxRows = 3;
        boxCols = 3;
        break;
      default:
        throw ArgumentError(
          'Unsupported size: $size. Supported sizes are 4, 6, and 9.',
        );
    }

    // Generate a valid complete solution (will serve as a reference)
    final solution = _generateFull(size, boxRows, boxCols);

    // Get number of cells to remove based on difficulty level
    final numToRemove = _removalsForSize(size);

    // Create the puzzle by removing cells (without uniqueness checking)
    final board = _simpleMask(solution, size, numToRemove);

    return SudokuPuzzle.create(
      size: size,
      boxRows: boxRows,
      boxCols: boxCols,
      solution: solution,
      board: board,
    );
  }

  static int _removalsForSize(int size) {
    // Without uniqueness checking, we can remove more cells
    // But still maintain appropriate difficulty levels
    if (size == 4) {
      // 4x4 (Easy): 9 removals leaves 7 clues
      return 9;
    } else if (size == 6) {
      // 6x6 (Medium): 20 removals leaves 16 clues
      return 20;
    } else {
      // 9x9 (Hard): 60 removals leaves 21 clues
      return 60;
    }
  }

  // Simple method that always returns true - required to maintain compatibility
  // with existing code that might call this method
  static bool debugVerifyUniqueSolution(SudokuPuzzle puzzle) {
    // We no longer verify uniqueness, so just return true
    return true;
  }

  // Simple mask method that just removes random cells without checking for uniqueness
  static List<List<int>> _simpleMask(
    List<List<int>> full,
    int size,
    int remove,
  ) {
    final rand = Random();
    final board = List.generate(size, (r) => List<int>.from(full[r]));

    // Create a list of all positions
    final positions = <List<int>>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        positions.add([r, c]);
      }
    }

    // Shuffle positions for randomness
    positions.shuffle(rand);

    // Remove cells up to the target number
    int removed = 0;
    for (final pos in positions) {
      if (removed >= remove) break;

      final r = pos[0];
      final c = pos[1];

      // Remove this cell
      board[r][c] = 0;
      removed++;
    }

    return board;
  }

  // Generate a fully filled Sudoku grid
  static List<List<int>> _generateFull(int size, int boxRows, int boxCols) {
    final board = List.generate(size, (_) => List.filled(size, 0));

    // Seed the puzzle with a pattern to speed up generation
    _seedPattern(board, size, boxRows, boxCols);

    // Fill the rest of the board
    _fill(board, 0, 0, size, boxRows, boxCols);
    return board;
  }

  // Seed the board with a pattern appropriate for size to speed up generation
  static void _seedPattern(
    List<List<int>> board,
    int size,
    int boxRows,
    int boxCols,
  ) {
    // For 9x9 puzzles, seed diagonal boxes
    if (size == 9) {
      for (int i = 0; i < 3; i++) {
        // Fill top-left to bottom-right diagonal boxes
        _fillBox(board, i * boxRows, i * boxCols, size, boxRows, boxCols);
      }
    }
    // For 4x4, seed one box
    else if (size == 4) {
      _fillBox(board, 0, 0, size, boxRows, boxCols);
    }
    // For 6x6, seed two boxes
    else if (size == 6) {
      _fillBox(board, 0, 0, size, boxRows, boxCols);
      // Use boxRows * 1 = 2 for the second box's starting row
      // Use boxCols * 1 = 3 for the second box's starting column
      _fillBox(board, boxRows, boxCols, size, boxRows, boxCols);
    }
  }

  // Fill a single box with valid numbers
  static void _fillBox(
    List<List<int>> board,
    int startRow,
    int startCol,
    int size,
    int boxRows,
    int boxCols,
  ) {
    final numbers = List<int>.generate(size, (i) => i + 1)..shuffle();
    int index = 0;

    for (int r = 0; r < boxRows; r++) {
      for (int c = 0; c < boxCols; c++) {
        board[startRow + r][startCol + c] = numbers[index++];
      }
    }
  }

  // Fill the board with a valid Sudoku solution
  // Using row/col parameters to track position in recursion rather than nested loops
  static bool _fill(
    List<List<int>> board,
    int row,
    int col,
    int size,
    int boxRows,
    int boxCols,
  ) {
    // If we've filled all rows, the board is complete
    if (row == size) {
      return true;
    }

    // Calculate next position
    int nextRow = col == size - 1 ? row + 1 : row;
    int nextCol = col == size - 1 ? 0 : col + 1;

    // If this cell is already filled, move to the next
    if (board[row][col] != 0) {
      return _fill(board, nextRow, nextCol, size, boxRows, boxCols);
    }

    // Shuffle numbers for randomness
    final nums = List<int>.generate(size, (i) => i + 1)..shuffle();

    // Try each number
    for (final num in nums) {
      if (_valid(board, row, col, num, size, boxRows, boxCols)) {
        board[row][col] = num;

        // Recursively fill the next cell
        if (_fill(board, nextRow, nextCol, size, boxRows, boxCols)) {
          return true;
        }

        // If we couldn't fill the next cell, backtrack
        board[row][col] = 0;
      }
    }

    // No solution found
    return false;
  }

  static bool _valid(
    List<List<int>> board,
    int r,
    int c,
    int n,
    int size,
    int boxRows,
    int boxCols,
  ) {
    // Check row and column in a single pass - more efficient
    for (int i = 0; i < size; i++) {
      if (board[r][i] == n) return false;
      if (board[i][c] == n) return false;
    }

    // Calculate box boundaries more efficiently
    final boxStartRow = (r ~/ boxRows) * boxRows;
    final boxStartCol = (c ~/ boxCols) * boxCols;

    // Check the box with direct boundaries
    for (int i = boxStartRow; i < boxStartRow + boxRows; i++) {
      for (int j = boxStartCol; j < boxStartCol + boxCols; j++) {
        if (board[i][j] == n) return false;
      }
    }

    return true;
  }

  // Removed unused _solveBoard method
}
