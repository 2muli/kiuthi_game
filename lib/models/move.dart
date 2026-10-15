import 'board_point.dart';

enum MoveKind { ordinary, capture }

/// One step: either a move to a neighbouring empty point, or one jump.
class Move {
  const Move({
    required this.pieceId,
    required this.from,
    required this.to,
    required this.kind,
    this.jumped,
    this.capturedPieceId,
  });

  final String pieceId;
  final BoardPoint from;
  final BoardPoint to;
  final MoveKind kind;
  final BoardPoint? jumped;
  final String? capturedPieceId;

  bool sameGeometry(Move other) {
    return from == other.from &&
        to == other.to &&
        kind == other.kind &&
        jumped == other.jumped;
  }

  @override
  String toString() =>
      '$kind $pieceId $from->$to${jumped == null ? '' : ' over $jumped'}';
}

/// A complete turn. An ordinary turn has one step. A capture turn has
/// every jump in the chain, so the opponent is never given the turn
/// halfway through.
class MoveSequence {
  const MoveSequence(this.steps);

  final List<Move> steps;

  int get captures =>
      steps.where((step) => step.kind == MoveKind.capture).length;

  bool sameGeometry(MoveSequence other) {
    if (steps.length != other.steps.length) return false;
    for (var i = 0; i < steps.length; i++) {
      if (!steps[i].sameGeometry(other.steps[i])) return false;
    }
    return true;
  }
}
