class SudokuPuzzle {
  final int size; // dynamic size (4,6,9)
  final int boxRows; // subgrid rows
  final int boxCols; // subgrid cols
  final List<List<int>> solution; // solved board
  final List<List<int>> board; // current board
  final List<List<bool>> fixedCells;

  SudokuPuzzle._(
    this.size,
    this.boxRows,
    this.boxCols,
    this.solution,
    this.board,
    this.fixedCells,
  );

  factory SudokuPuzzle.create({
    required int size,
    required int boxRows,
    required int boxCols,
    required List<List<int>> solution,
    required List<List<int>> board,
  }) {
    final fixed = List.generate(
      size,
      (r) => List.generate(size, (c) => board[r][c] != 0),
    );
    return SudokuPuzzle._(size, boxRows, boxCols, solution, board, fixed);
  }

  bool isFixed(int row, int col) => fixedCells[row][col];
  int getValue(int row, int col) => board[row][col];
  void setValue(int row, int col, int value) {
    board[row][col] = value;
  }
}
