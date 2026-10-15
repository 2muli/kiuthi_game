import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/game_controller.dart';
import 'package:kiuthi_game/engine/move_generator.dart';
import 'package:kiuthi_game/engine/move_validator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/move.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  BoardState jumping() {
    return (PositionSetup()
          ..put(Player.red, 3, 2)
          ..put(Player.blue, 2, 2))
        .build();
  }

  test('a straight jump removes the opponent and gives up the turn', () {
    final state = jumping();
    final before = state.redCaptured;
    final jump = MoveGenerator.immediate(
      state,
      rules,
    ).singleWhere((move) => move.kind == MoveKind.capture);
    final next = GameFlow.applyStep(state, jump, rules);

    expect(next.pieceAt(const BoardPoint(2, 2)), isNull);
    expect(next.pieceAt(const BoardPoint(1, 2))!.owner, Player.red);
    expect(next.pieceAt(const BoardPoint(1, 2))!.hasCrossed, isFalse);
    expect(next.redCaptured, before + 1);
    expect(next.count(Player.blue), 0);
    expect(next.activePlayer, Player.blue);
    expect(next.chainPieceId, isNull);
  });

  test('a jump is rejected when the landing point is occupied', () {
    final state =
        (PositionSetup()
              ..put(Player.red, 3, 1)
              ..put(Player.blue, 2, 1)
              ..put(Player.red, 1, 1))
            .build();
    final moves = MoveGenerator.immediate(state, rules);
    expect(moves.any((move) => move.kind == MoveKind.capture), isFalse);
  });

  test('a jump is rejected when the path is not a straight connection', () {
    final state =
        (PositionSetup()
              ..put(Player.red, 3, 0)
              ..put(Player.blue, 2, 1))
            .build();
    final piece = state.pieceAt(const BoardPoint(3, 0))!;
    final crooked = Move(
      pieceId: piece.id,
      from: piece.position,
      to: const BoardPoint(1, 3),
      kind: MoveKind.capture,
      jumped: const BoardPoint(2, 1),
      capturedPieceId: state.pieceAt(const BoardPoint(2, 1))!.id,
    );
    expect(MoveValidator.isLegal(state, crooked, rules), isFalse);
  });
}
