import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/move_generator.dart';
import 'package:kiuthi_game/engine/move_validator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/move.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  test('opening red pieces have 13 quiet forward moves and no captures', () {
    final moves = MoveGenerator.immediate(BoardState.initial(), rules);
    expect(moves, hasLength(13));
    expect(moves.every((move) => move.kind == MoveKind.ordinary), isTrue);
    expect(
      moves.every((move) => move.from.row == 3 && move.to.row == 2),
      isTrue,
    );
  });

  test('a piece cannot move to a disconnected, occupied, or distant point', () {
    final setup = PositionSetup()
      ..put(Player.red, 2, 2)
      ..put(Player.red, 2, 1);
    final state = setup.build();
    final moves = MoveGenerator.movesOf(
      state,
      Player.red,
      rules,
    ).where((move) => move.from == const BoardPoint(2, 2));

    expect(moves.any((move) => move.to == const BoardPoint(2, 3)), isTrue);
    expect(moves.any((move) => move.to == const BoardPoint(2, 1)), isFalse);
    expect(moves.any((move) => move.to == const BoardPoint(0, 2)), isFalse);
    expect(moves.any((move) => move.to == const BoardPoint(2, 0)), isFalse);

    final handmade = Move(
      pieceId: state.pieceAt(const BoardPoint(2, 2))!.id,
      from: const BoardPoint(2, 2),
      to: const BoardPoint(0, 0),
      kind: MoveKind.ordinary,
    );
    expect(MoveValidator.isLegal(state, handmade, rules), isFalse);
  });
}
