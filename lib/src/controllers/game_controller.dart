import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/sudoku_puzzle.dart';
import '../services/sudoku_generator_improved.dart' as generator;

// Reason for a loss to customize messaging
enum LossReason { timeUp, mistakes }

class GameController extends ChangeNotifier {
  int boardSize = 9; // dynamic size
  Duration? timeLimit;
  Duration elapsed = Duration.zero;
  bool isWin = false;
  bool isLoss = false;
  LossReason? lossReason; // differentiate loss type
  bool resultDialogShown = false; // prevent duplicate dialogs
  bool statsRecorded = false; // prevent duplicate stat writes
  DateTime? _startTime;
  void Function()? onWin;
  void Function()? onLoss;
  late final Ticker _ticker;

  late SudokuPuzzle puzzle;

  int selectedRow = -1;
  int selectedCol = -1;

  // Mistake tracking
  int mistakes = 0;
  int mistakeLimit = 3;

  // Undo stack (future) placeholder; redo omitted

  int? lastOldRating;
  int? lastNewRating;
  int? lastDelta;

  GameController() {
    _ticker = Ticker(_onTick);
    newGame(size: 9);
  }

  void newGame({required int size}) {
    boardSize = size;
    puzzle = generator.SudokuGenerator.generate(size: size);

    // We no longer verify uniqueness of solutions
    // The game will accept any valid solution that follows Sudoku rules

    selectedRow = -1;
    selectedCol = -1;
    isWin = false;
    isLoss = false;
    lossReason = null;
    resultDialogShown = false;
    statsRecorded = false;
    elapsed = Duration.zero;
    mistakes = 0;
    mistakeLimit = size == 4
        ? 1 // lowered to 1 for easy
        : size == 6
        ? 4 // medium
        : 5; // hard
    timeLimit = _getTimeLimit(size);
    _startTime = DateTime.now();
    _ticker.start();
    lastOldRating = null;
    lastNewRating = null;
    lastDelta = null;
    notifyListeners();
  }

  Duration _getTimeLimit(int size) {
    if (size == 4) return const Duration(minutes: 1, seconds: 30); // Easy
    if (size == 6) return const Duration(minutes: 5); // Medium updated from 10
    return const Duration(minutes: 15); // Hard 9x9
  }

  void _onTick(Duration tickElapsed) {
    if (_startTime == null || isWin || isLoss) return;
    elapsed = DateTime.now().difference(_startTime!);
    if (elapsed >= (timeLimit ?? Duration.zero)) {
      isLoss = true;
      lossReason = LossReason.timeUp;
      _ticker.stop();
      if (onLoss != null) onLoss!();
    }
    notifyListeners();
  }

  bool _isConflict(int row, int col, int value) {
    // If value is 0 (clearing the cell), there's no conflict
    if (value == 0) return false;

    // Check row for duplicates
    for (int i = 0; i < boardSize; i++) {
      if (puzzle.getValue(row, i) == value && i != col) return true;
    }

    // Check column for duplicates
    for (int i = 0; i < boardSize; i++) {
      if (puzzle.getValue(i, col) == value && i != row) return true;
    }

    // Check box for duplicates
    final boxRows = puzzle.boxRows;
    final boxCols = puzzle.boxCols;
    final br = (row ~/ boxRows) * boxRows;
    final bc = (col ~/ boxCols) * boxCols;
    for (int r = 0; r < boxRows; r++) {
      for (int c = 0; c < boxCols; c++) {
        final rr = br + r;
        final cc = bc + c;
        if (rr == row && cc == col) continue;
        if (puzzle.getValue(rr, cc) == value) return true;
      }
    }

    // No Sudoku rule conflicts
    return false;
  }

  void checkWin() {
    // Check if the board is filled completely and valid
    if (_isBoardComplete()) {
      // Accept any valid solution that follows Sudoku rules
      isWin = true;
      _ticker.stop();
      if (onWin != null) onWin!();
      notifyListeners();

      // Debug message
      if (kDebugMode) {
        print('Player completed a valid Sudoku solution!');
      }

      notifyListeners();
    }
  }

  bool _isBoardComplete() {
    // First pass: Check for empty cells
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (puzzle.getValue(r, c) == 0) return false;
      }
    }

    // Second pass: Check each row, column and box for valid Sudoku rules

    // Check rows
    for (int r = 0; r < boardSize; r++) {
      final seen = List<bool>.filled(boardSize + 1, false);
      for (int c = 0; c < boardSize; c++) {
        final val = puzzle.getValue(r, c);
        if (seen[val]) return false; // Duplicate in row
        seen[val] = true;
      }
    }

    // Check columns
    for (int c = 0; c < boardSize; c++) {
      final seen = List<bool>.filled(boardSize + 1, false);
      for (int r = 0; r < boardSize; r++) {
        final val = puzzle.getValue(r, c);
        if (seen[val]) return false; // Duplicate in column
        seen[val] = true;
      }
    }

    // Check boxes
    final boxRows = puzzle.boxRows;
    final boxCols = puzzle.boxCols;
    for (int br = 0; br < boardSize ~/ boxRows; br++) {
      for (int bc = 0; bc < boardSize ~/ boxCols; bc++) {
        final seen = List<bool>.filled(boardSize + 1, false);
        for (int r = 0; r < boxRows; r++) {
          for (int c = 0; c < boxCols; c++) {
            final val = puzzle.getValue(br * boxRows + r, bc * boxCols + c);
            if (seen[val]) return false; // Duplicate in box
            seen[val] = true;
          }
        }
      }
    }

    return true;
  }

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void setValue(int value) {
    // Early exit checks
    if (selectedRow < 0 || selectedCol < 0) return;
    if (puzzle.isFixed(selectedRow, selectedCol)) return;
    if (isWin || isLoss) {
      // Ensure we don't process any more moves after game is over
      return;
    }

    // Set the value in the puzzle
    puzzle.setValue(selectedRow, selectedCol, value);

    // Check for conflicts (Sudoku rules violation)
    if (_isConflict(selectedRow, selectedCol, value)) {
      mistakes++;
      if (mistakes >= mistakeLimit && !isLoss && !isWin) {
        isLoss = true;
        lossReason = LossReason.mistakes;
        _ticker.stop();
        resultDialogShown = false; // Reset to ensure dialog shows
        // statsRecorded intentionally NOT reset here to avoid duplicate writes

        if (onLoss != null) onLoss!();
      }
    }
    // No need to check against solution - we only care if rules are followed

    // Check for win condition
    checkWin();
    notifyListeners();
  }

  void clearCell() {
    if (selectedRow < 0 || selectedCol < 0) return;
    if (puzzle.isFixed(selectedRow, selectedCol)) return;
    puzzle.setValue(selectedRow, selectedCol, 0);
    notifyListeners();
  }

  double get completionPercent {
    int filled = 0;
    final total = boardSize * boardSize;
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (puzzle.getValue(r, c) != 0) filled++;
      }
    }
    return total == 0 ? 0 : filled / total;
  }

  // Shows a helpful tooltip explaining why a user's valid move might be marked as incorrect
  void showSolutionConflictHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Multiple Solutions'),
        content: const Text(
          'This puzzle has multiple valid solutions, but the game expects a specific one.\n\n'
          'Your move follows Sudoku rules but leads to a different solution than the expected one.\n\n'
          'Try exploring other options that may lead to the expected solution.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

// Simple ticker for timer
class Ticker {
  final void Function(Duration) onTick;
  bool _running = false;
  Duration _elapsed = Duration.zero;
  Ticker(this.onTick);
  void start() {
    if (_running) return;
    _running = true;
    _tick();
  }

  void stop() {
    _running = false;
  }

  void dispose() {
    _running = false;
  }

  void _tick() async {
    while (_running) {
      await Future.delayed(const Duration(seconds: 1));
      if (_running) {
        _elapsed += const Duration(seconds: 1);
        onTick(_elapsed);
      }
    }
  }
}
