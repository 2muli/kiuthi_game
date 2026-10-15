import '../models/board_point.dart';
import '../models/board_state.dart';
import '../models/move.dart';
import 'move_generator.dart';
import 'rule_config.dart';
import 'rule_engine.dart';

class MoveValidator {
  MoveValidator._();

  static bool isLegal(BoardState state, Move move, RuleConfig rules) {
    return MoveGenerator.immediate(state, rules).any(
      (candidate) =>
          candidate.pieceId == move.pieceId && candidate.sameGeometry(move),
    );
  }

  /// Maps an AI encoding onto the pieces actually on [state].
  ///
  /// Returns null if any step is illegal or the chain is left unfinished.
  /// Does not change [state].
  static List<Move>? adaptEncoded(
    BoardState state,
    List<int> encoded,
    RuleConfig rules,
  ) {
    if (encoded.isEmpty || encoded.length % 3 != 0) return null;
    var cursor = state;
    final moves = <Move>[];
    for (var i = 0; i < encoded.length; i += 3) {
      final fromIndex = encoded[i];
      final toIndex = encoded[i + 1];
      final jumpedIndex = encoded[i + 2];
      if (!_onBoard(fromIndex) || !_onBoard(toIndex)) return null;
      if (jumpedIndex < -1 || jumpedIndex >= BoardState.pointCount) {
        return null;
      }
      final from = BoardPoint.fromIndex(fromIndex);
      final to = BoardPoint.fromIndex(toIndex);
      final piece = cursor.pieceAt(from);
      if (piece == null) return null;
      final jumped = jumpedIndex >= 0
          ? BoardPoint.fromIndex(jumpedIndex)
          : null;
      final captured = jumped == null ? null : cursor.pieceAt(jumped)?.id;
      final move = Move(
        pieceId: piece.id,
        from: from,
        to: to,
        kind: jumped == null ? MoveKind.ordinary : MoveKind.capture,
        jumped: jumped,
        capturedPieceId: captured,
      );
      if (!isLegal(cursor, move, rules)) return null;
      moves.add(move);
      cursor = RuleEngine.apply(cursor, move, rules);
    }
    if (cursor.chainPieceId != null) return null;
    return moves;
  }

  static bool _onBoard(int index) =>
      index >= 0 && index < BoardState.pointCount;
}
