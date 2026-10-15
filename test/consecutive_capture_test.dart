import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/game_controller.dart';
import 'package:kiuthi_game/engine/move_generator.dart';
import 'package:kiuthi_game/engine/move_validator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  BoardState chain() {
    return (PositionSetup()
          ..put(Player.red, 4, 2)
          ..put(Player.blue, 3, 2)
          ..put(Player.blue, 1, 2))
        .build();
  }

  test('a double jump removes both pieces and only then switches turns', () {
    final state = chain();
    final sequences = MoveGenerator.completeSequences(
      state,
      rules,
    ).where((sequence) => sequence.captures == 2).toList();
    expect(sequences, hasLength(1));

    final first = sequences.single.steps.first;
    final mid = GameFlow.applyStep(state, first, rules);
    expect(mid.activePlayer, Player.red);
    expect(mid.chainPieceId, isNotNull);
    expect(mid.count(Player.blue), 1);
    expect(MoveGenerator.immediate(mid, rules), hasLength(1));

    final finished = GameFlow.applyStep(mid, sequences.single.steps[1], rules);
    expect(finished.count(Player.blue), 0);
    expect(finished.redCaptured, state.redCaptured + 2);
    expect(finished.activePlayer, Player.blue);
    expect(finished.chainPieceId, isNull);
    expect(finished.pieceAt(const BoardPoint(0, 2))!.hasCrossed, isTrue);
  });

  test('a chain may change direction, and that can be switched off', () {
    final state =
        (PositionSetup()
              ..put(Player.red, 4, 0)
              ..put(Player.blue, 3, 1)
              ..put(Player.blue, 1, 1))
            .build();
    final withChange = MoveGenerator.completeSequences(state, rules);
    expect(withChange.any((sequence) => sequence.captures == 2), isTrue);

    const straightOnly = RuleConfig(allowDirectionChangeBetweenJumps: false);
    final withoutChange = MoveGenerator.completeSequences(state, straightOnly);
    expect(withoutChange.any((sequence) => sequence.captures == 2), isFalse);
    expect(withoutChange.any((sequence) => sequence.captures == 1), isTrue);
  });

  test('an unfinished chain is not a complete computer turn', () {
    final state = chain();
    final sequence = MoveGenerator.completeSequences(
      state,
      rules,
    ).singleWhere((item) => item.captures == 2);
    final onlyFirst = [
      sequence.steps.first.from.index,
      sequence.steps.first.to.index,
      sequence.steps.first.jumped!.index,
    ];
    expect(MoveValidator.adaptEncoded(state, onlyFirst, rules), isNull);
  });
}
