import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/board_layout.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  test('the board has 25 points and the opening ranks', () {
    final state = BoardState.initial();
    expect(state.cells, hasLength(25));
    expect(state.count(Player.red), 10);
    expect(state.count(Player.blue), 10);
    for (var col = 0; col < 5; col++) {
      expect(state.pieceAt(BoardPoint(2, col)), isNull);
      expect(state.pieceAt(BoardPoint(0, col))!.owner, Player.blue);
      expect(state.pieceAt(BoardPoint(1, col))!.owner, Player.blue);
      expect(state.pieceAt(BoardPoint(3, col))!.owner, Player.red);
      expect(state.pieceAt(BoardPoint(4, col))!.owner, Player.red);
    }
    expect(state.activePlayer, Player.red);
    expect(state.pieces.every((piece) => piece.hasCrossed == false), isTrue);
  });

  test('paths are the eight-neighbour graph and stay symmetric', () {
    expect(BoardLayout.edges, hasLength(72));
    expect(BoardLayout.neighborsOf(const BoardPoint(0, 0)), hasLength(3));
    expect(BoardLayout.neighborsOf(const BoardPoint(0, 2)), hasLength(5));
    expect(BoardLayout.neighborsOf(const BoardPoint(2, 2)), hasLength(8));

    for (final (from, to) in BoardLayout.edges) {
      expect(BoardLayout.areAdjacent(from, to), isTrue);
      expect(BoardLayout.areAdjacent(to, from), isTrue);
      expect(from == to, isFalse);
    }

    const corner = BoardPoint(0, 0);
    expect(
      BoardLayout.neighborsOf(corner).map((point) => point.index).toSet(),
      {
        const BoardPoint(0, 1).index,
        const BoardPoint(1, 0).index,
        const BoardPoint(1, 1).index,
      },
    );
  });
}
