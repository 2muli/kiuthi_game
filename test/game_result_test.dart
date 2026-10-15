import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/game_controller.dart';
import 'package:kiuthi_game/engine/game_result_checker.dart';
import 'package:kiuthi_game/engine/move_generator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/difficulty.dart';
import 'package:kiuthi_game/models/game_result.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  test('capturing the last piece is a provisional elimination win', () {
    final state =
        (PositionSetup()
              ..put(Player.red, 3, 2)
              ..put(Player.blue, 2, 2))
            .build();
    final jump = MoveGenerator.immediate(
      state,
      rules,
    ).firstWhere((move) => move.to == const BoardPoint(1, 2));
    final next = GameFlow.applyStep(state, jump, rules);
    expect(next.status, GameStatus.redWins);
    expect(next.endReason, EndReason.eliminated);
  });

  test('a side with pieces but no move loses by immobilization', () {
    final setup = PositionSetup()..put(Player.red, 2, 2);
    const occupied = [
      BoardPoint(1, 1),
      BoardPoint(1, 2),
      BoardPoint(1, 3),
      BoardPoint(2, 1),
      BoardPoint(2, 3),
      BoardPoint(3, 1),
      BoardPoint(3, 2),
      BoardPoint(3, 3),
      BoardPoint(0, 0),
      BoardPoint(0, 2),
      BoardPoint(0, 4),
      BoardPoint(2, 0),
      BoardPoint(2, 4),
      BoardPoint(4, 0),
      BoardPoint(4, 2),
      BoardPoint(4, 4),
    ];
    for (final point in occupied) {
      setup.put(Player.blue, point.row, point.col);
    }
    final state = setup.build();
    final judged = GameResultChecker.judge(state, rules);
    expect(judged.status, GameStatus.blueWins);
    expect(judged.reason, EndReason.immobilized);
    expect(state.count(Player.red), greaterThan(0));
  });

  test('the same position three times is a provisional draw', () {
    var state =
        (PositionSetup()
              ..put(Player.red, 2, 0)
              ..put(Player.blue, 1, 4))
            .build();
    const steps = [(2, 1), (1, 3), (2, 0), (1, 4)];
    for (var cycle = 0; cycle < 2; cycle++) {
      for (final (row, col) in steps) {
        final move = MoveGenerator.immediate(state, rules).firstWhere(
          (candidate) => candidate.to.row == row && candidate.to.col == col,
        );
        state = GameFlow.applyStep(state, move, rules);
      }
    }
    expect(state.status, GameStatus.draw);
    expect(state.endReason, EndReason.repetition);
  });

  test('undo restores pieces, crossing, the chain, and the side to move', () {
    final start =
        (PositionSetup()
              ..put(Player.red, 4, 2)
              ..put(Player.blue, 3, 2)
              ..put(Player.blue, 1, 2))
            .build();
    final session = GameSession(state: start, difficulty: Difficulty.easy);
    final openingKey = session.state.positionKey;
    final first = session.legalMoves.firstWhere(
      (move) => move.to == const BoardPoint(2, 2),
    );
    expect(session.applyHumanMove(first), isTrue);
    expect(session.state.chainPieceId, isNotNull);
    expect(session.state.count(Player.blue), 1);

    expect(session.undo(), isTrue);
    expect(session.state.positionKey, openingKey);
    expect(session.state.chainPieceId, isNull);
    expect(session.state.count(Player.blue), 2);
    expect(session.state.activePlayer, Player.red);
    expect(session.state.redCaptured, start.redCaptured);
  });
}
