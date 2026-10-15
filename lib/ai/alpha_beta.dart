import '../engine/game_result_checker.dart';
import '../engine/move_generator.dart';
import '../engine/rule_config.dart';
import '../engine/rule_engine.dart';
import '../models/board_state.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'difficulty_config.dart';
import 'position_evaluator.dart';
import 'transposition_table.dart';

/// Minimax with alpha-beta pruning.
///
/// A capture chain is one ply: the opponent is not searched until the chain
/// ends. Threefold repetition is judged on the live game, not inside this
/// tree, so cached scores stay independent of the path that reached them.
class AlphaBetaSearch {
  AlphaBetaSearch({
    required this.rules,
    required this.config,
    required this.deadline,
    required this.table,
  });

  final RuleConfig rules;
  final DifficultyConfig config;
  final DateTime deadline;
  final TranspositionTable table;
  bool timedOut = false;

  MoveSequence choose(BoardState state, List<MoveSequence> sequences) {
    final ordered = _ordered(sequences, state.activePlayer);
    if (!config.iterative) {
      return _searchRoot(state, ordered, config.depth) ?? ordered.first;
    }

    MoveSequence? completed;
    for (var depth = 1; depth <= config.depth; depth++) {
      if (depth > 1 && !DateTime.now().isBefore(deadline)) break;
      timedOut = false;
      final found = _searchRoot(state, ordered, depth);
      if (found != null && !timedOut) {
        completed = found;
      } else {
        completed ??= found;
        break;
      }
    }
    return completed ?? ordered.first;
  }

  MoveSequence? _searchRoot(
    BoardState state,
    List<MoveSequence> ordered,
    int depth,
  ) {
    MoveSequence? best;
    var bestScore = -double.infinity;
    var alpha = -double.infinity;
    const beta = double.infinity;
    var finishedOne = false;

    for (final sequence in ordered) {
      if (finishedOne && !DateTime.now().isBefore(deadline)) {
        timedOut = true;
        break;
      }
      final child = _play(state, sequence);
      final score = _search(child, depth - 1, alpha, beta, 1);
      if (score > bestScore) {
        bestScore = score;
        best = sequence;
      }
      if (score > alpha) alpha = score;
      if (!timedOut) finishedOne = true;
      if (timedOut) break;
    }
    return best;
  }

  double _search(
    BoardState state,
    int depth,
    double alpha,
    double beta,
    int ply,
  ) {
    final judged = GameResultChecker.judge(state, rules);
    if (judged.isOver) return _terminal(judged, ply);
    if (depth <= 0) {
      return PositionEvaluator.evaluate(state, rules, config.weights);
    }
    if (!DateTime.now().isBefore(deadline)) {
      timedOut = true;
      return PositionEvaluator.evaluate(state, rules, config.weights);
    }

    final cached = table.probe(state, depth);
    if (cached != null) return cached;

    final sequences = _ordered(
      MoveGenerator.completeSequences(state, rules),
      state.activePlayer,
    );
    if (sequences.isEmpty) {
      final loss = state.activePlayer == Player.blue
          ? -PositionEvaluator.winScore + ply
          : PositionEvaluator.winScore - ply;
      return loss;
    }

    final maximizing = state.activePlayer == Player.blue;
    var value = maximizing ? -double.infinity : double.infinity;
    var cut = false;

    for (final sequence in sequences) {
      final child = _play(state, sequence);
      final score = _search(child, depth - 1, alpha, beta, ply + 1);
      if (maximizing) {
        if (score > value) value = score;
        if (value > alpha) alpha = value;
      } else {
        if (score < value) value = score;
        if (value < beta) beta = value;
      }
      if (alpha >= beta) {
        cut = true;
        break;
      }
      if (timedOut) break;
    }

    if (!cut && !timedOut) table.store(state, depth, value);
    return value;
  }

  double _terminal(GameResult judged, int ply) {
    switch (judged.status) {
      case GameStatus.blueWins:
        return PositionEvaluator.winScore - ply;
      case GameStatus.redWins:
        return -PositionEvaluator.winScore + ply;
      case GameStatus.draw:
      case GameStatus.ongoing:
        return 0;
    }
  }

  BoardState _play(BoardState state, MoveSequence sequence) {
    var cursor = state;
    for (final step in sequence.steps) {
      cursor = RuleEngine.apply(cursor, step, rules);
    }
    final judged = GameResultChecker.judge(cursor, rules);
    if (!judged.isOver) return cursor;
    return cursor.copyWith(status: judged.status, endReason: judged.reason);
  }

  static List<MoveSequence> _ordered(
    List<MoveSequence> sequences,
    Player player,
  ) {
    final copy = List<MoveSequence>.of(sequences);
    copy.sort((a, b) => _rank(b, player).compareTo(_rank(a, player)));
    return copy;
  }

  static int _rank(MoveSequence sequence, Player player) {
    final row = sequence.steps.last.to.row;
    final forward = player == Player.blue ? row : 4 - row;
    return sequence.captures * 100 + forward;
  }
}
