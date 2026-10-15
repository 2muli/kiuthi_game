import '../engine/game_result_checker.dart';
import '../engine/move_generator.dart';
import '../engine/rule_config.dart';
import '../engine/rule_engine.dart';
import '../models/board_state.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';

/// Starting weights. They are not claimed to be optimal.
///
/// Piece count is deliberately larger than mobility or progress so a capture
/// beats a quiet move. Threat is larger than Easy's variation window so a
/// move that hangs a piece loses to a safe alternative. Progress is small
/// because its value in Kiuthi is not confirmed. Tune from test positions
/// and play, then update the tests that lock these preferences.
class EvalWeights {
  const EvalWeights({
    required this.piece,
    required this.mobility,
    required this.attack,
    required this.threat,
    required this.chain,
    required this.progress,
  });

  final double piece;
  final double mobility;
  final double attack;
  final double threat;
  final double chain;
  final double progress;

  static const easy = EvalWeights(
    piece: 100,
    mobility: 2,
    attack: 16,
    threat: 24,
    chain: 8,
    progress: 2,
  );

  static const intermediate = EvalWeights(
    piece: 100,
    mobility: 3,
    attack: 18,
    threat: 22,
    chain: 12,
    progress: 3,
  );

  static const expert = EvalWeights(
    piece: 100,
    mobility: 4,
    attack: 20,
    threat: 26,
    chain: 16,
    progress: 4,
  );

  @override
  bool operator ==(Object other) {
    return other is EvalWeights &&
        other.piece == piece &&
        other.mobility == mobility &&
        other.attack == attack &&
        other.threat == threat &&
        other.chain == chain &&
        other.progress == progress;
  }

  @override
  int get hashCode =>
      Object.hash(piece, mobility, attack, threat, chain, progress);
}

/// Score from Blue's point of view. Higher is better for the computer.
class PositionEvaluator {
  PositionEvaluator._();

  static const double winScore = 100000;

  static double evaluate(
    BoardState state,
    RuleConfig rules,
    EvalWeights weights,
  ) {
    final judged = GameResultChecker.judge(state, rules);
    if (judged.status == GameStatus.blueWins) return winScore;
    if (judged.status == GameStatus.redWins) return -winScore;
    if (judged.status == GameStatus.draw) return 0;

    final blueMoves = MoveGenerator.movesOf(state, Player.blue, rules);
    final redMoves = MoveGenerator.movesOf(state, Player.red, rules);
    final blueAttacks = _attacks(blueMoves);
    final redAttacks = _attacks(redMoves);

    return (state.count(Player.blue) - state.count(Player.red)) *
            weights.piece +
        (blueMoves.length - redMoves.length) * weights.mobility +
        (blueAttacks - redAttacks) * weights.attack +
        (blueAttacks * weights.threat - redAttacks * weights.threat) +
        (_chains(state, blueMoves, rules) - _chains(state, redMoves, rules)) *
            weights.chain +
        (state.crossedCount(Player.blue) - state.crossedCount(Player.red)) *
            weights.progress;
  }

  static int _attacks(List<Move> moves) =>
      moves.where((move) => move.kind == MoveKind.capture).length;

  static int _chains(BoardState state, List<Move> moves, RuleConfig rules) {
    var chains = 0;
    for (final move in moves) {
      if (move.kind != MoveKind.capture) continue;
      final next = RuleEngine.apply(state, move, rules);
      if (next.chainPieceId != null) chains += 1;
    }
    return chains;
  }
}
