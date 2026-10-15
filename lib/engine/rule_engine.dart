import '../models/board_state.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'capture_engine.dart';
import 'rule_config.dart';

/// Edge-line and crossing checks, kept separate from search and painting.
///
/// A piece may move sideways or forward until it reaches the opponent's
/// last line. Backward steps are legal only after that piece has landed
/// there. The permission stays with that piece.
///
/// Red starts at the bottom, so forward is toward row 0 and the last line
/// is row 0. Blue starts at the top, so forward is toward row 4 and the
/// last line is row 4.
class EdgeLineRule {
  EdgeLineRule._();

  static int homeEdgeRow(Player owner) => owner == Player.red ? 4 : 0;

  static int opponentEdgeRow(Player owner) => owner == Player.red ? 0 : 4;

  /// True when the step moves closer to this piece's own edge.
  static bool isBackward({
    required Player owner,
    required int fromRow,
    required int toRow,
  }) {
    if (owner == Player.red) return toRow > fromRow;
    return toRow < fromRow;
  }

  static bool allowsLanding({
    required Player owner,
    required bool hasCrossed,
    required int fromRow,
    required int toRow,
    required RuleConfig rules,
  }) {
    if (!hasCrossed &&
        isBackward(owner: owner, fromRow: fromRow, toRow: toRow)) {
      return false;
    }
    if (!rules.mayEnterOpponentEdge && toRow == opponentEdgeRow(owner)) {
      return false;
    }
    return true;
  }

  static bool marksCrossed(Player owner, bool alreadyCrossed, int toRow) {
    return alreadyCrossed || toRow == opponentEdgeRow(owner);
  }
}

/// Applies one already-chosen step. Does not decide who won.
class RuleEngine {
  RuleEngine._();

  static BoardState apply(BoardState state, Move move, RuleConfig rules) {
    final moving = state.pieceAt(move.from);
    if (moving == null || moving.id != move.pieceId) {
      throw StateError('Move does not match the piece on ${move.from}.');
    }

    final cells = List<Piece?>.of(state.cells);
    cells[move.from.index] = null;
    var redCaptured = state.redCaptured;
    var blueCaptured = state.blueCaptured;

    if (move.kind == MoveKind.capture) {
      final jumped = move.jumped;
      if (jumped == null) {
        throw StateError('A capture needs the jumped point.');
      }
      cells[jumped.index] = null;
      if (moving.owner == Player.red) {
        redCaptured += 1;
      } else {
        blueCaptured += 1;
      }
    }

    final crossed = EdgeLineRule.marksCrossed(
      moving.owner,
      moving.hasCrossed,
      move.to.row,
    );
    final moved = moving.copyWith(position: move.to, hasCrossed: crossed);
    cells[move.to.index] = moved;

    if (move.kind == MoveKind.ordinary) {
      return BoardState(
        cells: cells,
        activePlayer: state.activePlayer.opponent,
        status: state.status,
        endReason: state.endReason,
        redCaptured: redCaptured,
        blueCaptured: blueCaptured,
        positionHistory: state.positionHistory,
      );
    }

    final unitRow = (move.to.row - move.from.row) ~/ 2;
    final unitCol = (move.to.col - move.from.col) ~/ 2;
    final further = CaptureEngine.legalJumps(
      cells: cells,
      piece: moved,
      rules: rules,
      requiredDeltaRow: rules.allowDirectionChangeBetweenJumps ? null : unitRow,
      requiredDeltaCol: rules.allowDirectionChangeBetweenJumps ? null : unitCol,
    );

    if (further.isEmpty) {
      return BoardState(
        cells: cells,
        activePlayer: state.activePlayer.opponent,
        status: state.status,
        endReason: state.endReason,
        redCaptured: redCaptured,
        blueCaptured: blueCaptured,
        positionHistory: state.positionHistory,
      );
    }

    return BoardState(
      cells: cells,
      activePlayer: state.activePlayer,
      status: state.status,
      endReason: state.endReason,
      redCaptured: redCaptured,
      blueCaptured: blueCaptured,
      chainPieceId: moved.id,
      chainDeltaRow: unitRow,
      chainDeltaCol: unitCol,
      positionHistory: state.positionHistory,
    );
  }
}
