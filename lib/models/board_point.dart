/// An intersection on the 5×5 Kiuthi board.
///
/// Row 0 is the top edge (Blue's home line). Row 4 is the bottom edge
/// (Red's home line). Columns run from 0 on the left to 4 on the right.
class BoardPoint {
  const BoardPoint(this.row, this.col);

  final int row;
  final int col;

  static const int span = 5;

  int get index => row * span + col;

  bool get isOnBoard => row >= 0 && row < span && col >= 0 && col < span;

  BoardPoint shifted(int dRow, int dCol) => BoardPoint(row + dRow, col + dCol);

  static BoardPoint fromIndex(int index) =>
      BoardPoint(index ~/ span, index % span);

  @override
  bool operator ==(Object other) =>
      other is BoardPoint && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}
