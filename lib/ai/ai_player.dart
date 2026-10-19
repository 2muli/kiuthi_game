import 'dart:math';

import '../engine/move_generator.dart';
import '../engine/rule_config.dart';
import '../engine/rule_engine.dart';
import '../models/board_point.dart';
import '../models/board_state.dart';
import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'difficulty_config.dart';
import 'minimax.dart';
import 'position_evaluator.dart';

/// Local computer opponent. No network calls.
class AiPlayer {
  AiPlayer._();

  static List<int> choose({
    required BoardState state,
    required Difficulty difficulty,
    required RuleConfig rules,
    required int seed,
  }) {
    if (state.status != GameStatus.ongoing) return const [];
    if (state.activePlayer != Player.blue) return const [];
    final sequences = MoveGenerator.completeSequences(state, rules);
    if (sequences.isEmpty) return const [];

    final config = DifficultyConfig.of(difficulty);
    if (_isComputerOpening(state)) {
      final random = Random(seed);
      return _encode(sequences[random.nextInt(sequences.length)]);
    }
    final MoveSequence chosen;
    if (config.useMinimax) {
      chosen = Minimax.choose(
        state: state,
        sequences: sequences,
        rules: rules,
        config: config,
      );
    } else {
      chosen = _easy(state, sequences, rules, config, seed);
    }
    if (!_isOffered(chosen, sequences)) return _encode(sequences.first);
    return _encode(chosen);
  }

  /// Blue's first turn, after one human move and before Blue has replied.
  static bool _isComputerOpening(BoardState state) {
    return state.activePlayer == Player.blue &&
        state.chainPieceId == null &&
        state.positionHistory.length == 2;
  }

  static MoveSequence _easy(
    BoardState state,
    List<MoveSequence> sequences,
    RuleConfig rules,
    DifficultyConfig config,
    int seed,
  ) {
    final scored = <(MoveSequence, double)>[];
    for (final sequence in sequences) {
      final after = _play(state, sequence, rules);
      scored.add((
        sequence,
        PositionEvaluator.evaluate(after, rules, config.weights),
      ));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    final best = scored.first.$2;
    final pool = scored
        .where((entry) => best - entry.$2 <= config.variation)
        .map((entry) => entry.$1)
        .toList();
    final random = Random(seed);
    return pool[random.nextInt(pool.length)];
  }

  static BoardState _play(
    BoardState state,
    MoveSequence sequence,
    RuleConfig rules,
  ) {
    var cursor = state;
    for (final step in sequence.steps) {
      cursor = RuleEngine.apply(cursor, step, rules);
    }
    return cursor;
  }

  static bool _isOffered(MoveSequence chosen, List<MoveSequence> sequences) {
    return sequences.any(chosen.sameGeometry);
  }

  static List<int> _encode(MoveSequence sequence) {
    final encoded = <int>[];
    for (final step in sequence.steps) {
      encoded
        ..add(step.from.index)
        ..add(step.to.index)
        ..add(step.jumped?.index ?? -1);
    }
    return encoded;
  }
}

/// Plain-integer request for [kiuthiChooseMove].
List<int> encodeAiPayload({
  required BoardState state,
  required Difficulty difficulty,
  required RuleConfig rules,
  required int seed,
}) {
  return [
    1,
    difficulty.index,
    rules.capturesCompulsory ? 1 : 0,
    seed,
    state.activePlayer == Player.red ? 0 : 1,
    ...state.cellCodes,
  ];
}

/// Isolate entry point. The argument and result are plain integers so they
/// can cross the isolate boundary.
List<int> kiuthiChooseMove(List<int> payload) {
  if (payload.length != 30 || payload.first != 1) return const [];
  final difficulty = Difficulty.values[payload[1]];
  final rules = RuleConfig.standard.copyWith(
    capturesCompulsory: payload[2] == 1,
  );
  final seed = payload[3];
  final active = payload[4] == 0 ? Player.red : Player.blue;
  final state = _decode(payload.sublist(5), active);
  return AiPlayer.choose(
    state: state,
    difficulty: difficulty,
    rules: rules,
    seed: seed,
  );
}

BoardState _decode(List<int> codes, Player active) {
  final cells = List<Piece?>.filled(25, null);
  var red = 0;
  var blue = 0;
  var redLeft = 0;
  var blueLeft = 0;
  for (var i = 0; i < 25; i++) {
    final code = codes[i];
    if (code == 0) continue;
    final owner = code <= 2 ? Player.red : Player.blue;
    final crossed = code == 2 || code == 4;
    final id = owner == Player.red ? 'R${red++}' : 'B${blue++}';
    if (owner == Player.red) {
      redLeft += 1;
    } else {
      blueLeft += 1;
    }
    final point = BoardPoint.fromIndex(i);
    cells[i] = Piece(
      id: id,
      owner: owner,
      position: point,
      hasCrossed: crossed,
    );
  }
  final state = BoardState(
    cells: cells,
    activePlayer: active,
    redCaptured: 10 - blueLeft,
    blueCaptured: 10 - redLeft,
  );
  return state.copyWith(positionHistory: [state.positionKey]);
}
