import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/ai/ai_player.dart';
import 'package:kiuthi_game/ai/difficulty_config.dart';
import 'package:kiuthi_game/ai/position_evaluator.dart';
import 'package:kiuthi_game/engine/game_controller.dart';
import 'package:kiuthi_game/engine/move_validator.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_point.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/difficulty.dart';
import 'package:kiuthi_game/models/piece.dart';

void main() {
  const rules = RuleConfig.standard;

  BoardState blueToMove() {
    return BoardState.initial().copyWith(activePlayer: Player.blue);
  }

  test('difficulties use different search setups and weights', () {
    final easy = DifficultyConfig.of(Difficulty.easy);
    final middle = DifficultyConfig.of(Difficulty.intermediate);
    final expert = DifficultyConfig.of(Difficulty.expert);

    expect(easy.useMinimax, isFalse);
    expect(middle.useMinimax, isTrue);
    expect(expert.useMinimax, isTrue);
    expect(easy.depth, lessThan(middle.depth));
    expect(middle.depth, lessThan(expert.depth));
    expect(expert.iterative, isTrue);
    expect(middle.iterative, isFalse);
    expect(easy.variation, greaterThan(0));
    expect(middle.variation, 0);
    expect(easy.weights, isNot(middle.weights));
    expect(middle.weights, isNot(expert.weights));
    expect(expert.budget.inMilliseconds, greaterThan(0));
  });

  test('every difficulty returns a legal move for Blue', () {
    final state = blueToMove();
    for (final difficulty in Difficulty.values) {
      final encoded = AiPlayer.choose(
        state: state,
        difficulty: difficulty,
        rules: rules,
        seed: 7,
      );
      final moves = MoveValidator.adaptEncoded(state, encoded, rules);
      expect(moves, isNotNull, reason: difficulty.name);
      expect(moves, isNotEmpty);
    }
  });

  test('a clear capture is preferred to a quiet move', () {
    final state =
        (PositionSetup()
              ..put(Player.blue, 1, 1)
              ..put(Player.red, 2, 1))
            .build(active: Player.blue);
    for (final difficulty in Difficulty.values) {
      final encoded = AiPlayer.choose(
        state: state,
        difficulty: difficulty,
        rules: rules,
        seed: 3,
      );
      expect(encoded[2], isNot(-1), reason: difficulty.name);
      expect(encoded[1], const BoardPoint(3, 1).index);
    }
  });

  test('Easy varies among similar quiet moves and still stays legal', () {
    final state = blueToMove();
    final seen = <String>{};
    for (var seed = 0; seed < 16; seed++) {
      final encoded = AiPlayer.choose(
        state: state,
        difficulty: Difficulty.easy,
        rules: rules,
        seed: seed,
      );
      expect(MoveValidator.adaptEncoded(state, encoded, rules), isNotNull);
      seen.add(encoded.take(2).join(','));
    }
    expect(seen.length, greaterThan(1));
  });

  test('more pieces score better, and a hanging piece scores worse', () {
    final safe =
        (PositionSetup()
              ..put(Player.blue, 0, 0)
              ..put(Player.red, 4, 4))
            .build(active: Player.blue);
    final extra =
        (PositionSetup()
              ..put(Player.blue, 0, 0)
              ..put(Player.blue, 0, 1)
              ..put(Player.red, 4, 4))
            .build(active: Player.blue);
    final calm =
        (PositionSetup()
              ..put(Player.blue, 0, 0)
              ..put(Player.red, 4, 3)
              ..put(Player.red, 4, 4))
            .build(active: Player.blue);
    final hanging =
        (PositionSetup()
              ..put(Player.blue, 1, 2)
              ..put(Player.red, 2, 2)
              ..put(Player.red, 3, 2))
            .build(active: Player.blue);

    final weights = EvalWeights.easy;
    expect(
      PositionEvaluator.evaluate(extra, rules, weights),
      greaterThan(PositionEvaluator.evaluate(safe, rules, weights)),
    );
    expect(
      PositionEvaluator.evaluate(hanging, rules, weights),
      lessThan(PositionEvaluator.evaluate(calm, rules, weights)),
    );
  });

  test('a result for an older position is not applied', () {
    final state = blueToMove();
    final session = GameSession(state: state, difficulty: Difficulty.easy);
    final token = session.guard.start();
    final key = session.state.positionKey;
    final moves = MoveValidator.adaptEncoded(
      session.state,
      AiPlayer.choose(
        state: session.state,
        difficulty: Difficulty.intermediate,
        rules: rules,
        seed: 1,
      ),
      rules,
    );
    session.restart();
    expect(session.guard.accepts(token), isFalse);
    expect(session.applyComputerSequence(moves!, stateKey: key), isFalse);
    expect(session.state.count(Player.red), 10);
    expect(session.state.count(Player.blue), 10);
  });

  test('Expert returns within its budget on the opening reply', () {
    final watch = Stopwatch()..start();
    final encoded = AiPlayer.choose(
      state: blueToMove(),
      difficulty: Difficulty.expert,
      rules: rules,
      seed: 1,
    );
    watch.stop();
    expect(encoded, isNotEmpty);
    expect(
      watch.elapsed,
      lessThan(DifficultyConfig.of(Difficulty.expert).budget * 4),
    );
  });
}
