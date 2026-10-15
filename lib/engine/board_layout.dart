import '../models/board_point.dart';

/// The only definition of legal Kiuthi paths.
///
/// Assumption: the specification refers to a diagram that was not included.
/// This layout connects every pair of intersections that are one step apart
/// in any of the eight compass directions and that both lie on the board.
/// Movement and captures must use [neighborsOf]. Do not add shortcuts
/// anywhere else.
class BoardLayout {
  BoardLayout._();

  static const int rows = 5;
  static const int columns = 5;

  static const List<(int, int)> directions = [
    (-1, -1),
    (-1, 0),
    (-1, 1),
    (0, -1),
    (0, 1),
    (1, -1),
    (1, 0),
    (1, 1),
  ];

  static final List<List<BoardPoint>> _neighbors = _buildNeighbors();
  static final List<Set<int>> _neighborIndexes = [
    for (final list in _neighbors) {for (final point in list) point.index},
  ];

  /// Each undirected connection once, lower index first.
  static final List<(BoardPoint, BoardPoint)> edges = _buildEdges();

  static List<BoardPoint> neighborsOf(BoardPoint point) =>
      _neighbors[point.index];

  static bool areAdjacent(BoardPoint a, BoardPoint b) {
    if (!a.isOnBoard || !b.isOnBoard) return false;
    return _neighborIndexes[a.index].contains(b.index);
  }

  static List<List<BoardPoint>> _buildNeighbors() {
    final neighbors = List<List<BoardPoint>>.generate(
      rows * columns,
      (_) => <BoardPoint>[],
    );
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final origin = BoardPoint(row, col);
        for (final (dRow, dCol) in directions) {
          final next = origin.shifted(dRow, dCol);
          if (next.isOnBoard) neighbors[origin.index].add(next);
        }
      }
    }
    return neighbors;
  }

  static List<(BoardPoint, BoardPoint)> _buildEdges() {
    final built = <(BoardPoint, BoardPoint)>[];
    for (var index = 0; index < rows * columns; index++) {
      final origin = BoardPoint.fromIndex(index);
      for (final neighbor in _neighbors[index]) {
        if (neighbor.index > index) built.add((origin, neighbor));
      }
    }
    return built;
  }
}
