import '../models/move.dart';
import '../models/piece.dart';
import 'board_layout.dart';
import 'rule_config.dart';
import 'rule_engine.dart';

/// Jump generation. A capture is a state change: the jumped piece is removed
/// by [RuleEngine.apply], not by the painter.
class CaptureEngine {
  CaptureEngine._();

  static List<Move> legalJumps({
    required List<Piece?> cells,
    required Piece piece,
    required RuleConfig rules,
    int? requiredDeltaRow,
    int? requiredDeltaCol,
  }) {
    final jumps = <Move>[];
    for (final (dRow, dCol) in BoardLayout.directions) {
      if (requiredDeltaRow != null &&
          (dRow != requiredDeltaRow || dCol != requiredDeltaCol)) {
        continue;
      }
      final over = piece.position.shifted(dRow, dCol);
      final landing = piece.position.shifted(dRow * 2, dCol * 2);
      if (!over.isOnBoard || !landing.isOnBoard) continue;
      if (!BoardLayout.areAdjacent(piece.position, over)) continue;
      if (!BoardLayout.areAdjacent(over, landing)) continue;

      final middle = cells[over.index];
      if (middle == null || middle.owner == piece.owner) continue;
      if (cells[landing.index] != null) continue;
      if (!EdgeLineRule.allowsLanding(
        owner: piece.owner,
        hasCrossed: piece.hasCrossed,
        fromRow: piece.position.row,
        toRow: landing.row,
        rules: rules,
      )) {
        continue;
      }

      jumps.add(
        Move(
          pieceId: piece.id,
          from: piece.position,
          to: landing,
          kind: MoveKind.capture,
          jumped: over,
          capturedPieceId: middle.id,
        ),
      );
    }
    return jumps;
  }
}
