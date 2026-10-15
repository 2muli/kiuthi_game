import '../models/board_state.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'board_layout.dart';
import 'capture_engine.dart';
import 'rule_config.dart';
import 'rule_engine.dart';

/// Legal steps and complete turns. The interface asks this module what is
/// legal; it does not decide for itself.
class MoveGenerator {
  MoveGenerator._();

  static List<Move> immediate(BoardState state, RuleConfig rules) {
    if (state.status != GameStatus.ongoing) return const [];
    if (state.chainPieceId != null) {
      final piece = state.pieceById(state.chainPieceId!);
      if (piece == null) return const [];
      return CaptureEngine.legalJumps(
        cells: state.cells,
        piece: piece,
        rules: rules,
        requiredDeltaRow: rules.allowDirectionChangeBetweenJumps
            ? null
            : state.chainDeltaRow,
        requiredDeltaCol: rules.allowDirectionChangeBetweenJumps
            ? null
            : state.chainDeltaCol,
      );
    }
    return movesOf(state, state.activePlayer, rules);
  }

  /// Mobility for either side, ignoring whose turn it is.
  /// Used by the evaluator. Not used to apply a move.
  static List<Move> movesOf(BoardState state, Player player, RuleConfig rules) {
    final captures = <Move>[];
    final quiet = <Move>[];
    for (final piece in state.pieces) {
      if (piece.owner != player) continue;
      captures.addAll(
        CaptureEngine.legalJumps(
          cells: state.cells,
          piece: piece,
          rules: rules,
        ),
      );
      quiet.addAll(_quiet(state, piece, rules));
    }
    if (rules.capturesCompulsory && captures.isNotEmpty) return captures;
    return [...captures, ...quiet];
  }

  static List<Move> _quiet(BoardState state, Piece piece, RuleConfig rules) {
    final moves = <Move>[];
    for (final neighbor in BoardLayout.neighborsOf(piece.position)) {
      if (state.pieceAt(neighbor) != null) continue;
      if (!EdgeLineRule.allowsLanding(
        owner: piece.owner,
        hasCrossed: piece.hasCrossed,
        fromRow: piece.position.row,
        toRow: neighbor.row,
        rules: rules,
      )) {
        continue;
      }
      moves.add(
        Move(
          pieceId: piece.id,
          from: piece.position,
          to: neighbor,
          kind: MoveKind.ordinary,
        ),
      );
    }
    return moves;
  }

  /// Every legal turn from this position. A capture turn includes the
  /// whole chain, with a branch wherever the player may choose the next jump.
  static List<MoveSequence> completeSequences(
    BoardState state,
    RuleConfig rules,
  ) {
    final sequences = <MoveSequence>[];
    for (final move in immediate(state, rules)) {
      if (move.kind == MoveKind.ordinary) {
        sequences.add(MoveSequence([move]));
      } else {
        _expand(state, rules, move, [move], sequences);
      }
    }
    return sequences;
  }

  static void _expand(
    BoardState state,
    RuleConfig rules,
    Move move,
    List<Move> path,
    List<MoveSequence> into,
  ) {
    final next = RuleEngine.apply(state, move, rules);
    final jumps = next.chainPieceId == null
        ? const <Move>[]
        : immediate(next, rules);
    if (next.chainPieceId == null || jumps.isEmpty) {
      into.add(MoveSequence(List<Move>.unmodifiable(path)));
      return;
    }
    for (final jump in jumps) {
      path.add(jump);
      _expand(next, rules, jump, path, into);
      path.removeLast();
    }
  }
}
