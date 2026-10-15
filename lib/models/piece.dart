import 'board_point.dart';

/// The two sides. Red is the human; Blue is the computer.
enum Player {
  red,
  blue;

  Player get opponent => this == Player.red ? Player.blue : Player.red;

  String get label => this == Player.red ? 'Red' : 'Blue';

  static Player parse(String value) {
    return Player.values.firstWhere(
      (player) => player.name == value,
      orElse: () => throw FormatException('Unknown player: $value'),
    );
  }
}

/// One stone on the board.
///
/// [hasCrossed] is tracked per piece. It becomes true when that piece
/// lands on the opponent's last line, and it stays true afterwards.
class Piece {
  const Piece({
    required this.id,
    required this.owner,
    required this.position,
    required this.hasCrossed,
  });

  final String id;
  final Player owner;
  final BoardPoint position;
  final bool hasCrossed;

  Piece copyWith({BoardPoint? position, bool? hasCrossed}) {
    return Piece(
      id: id,
      owner: owner,
      position: position ?? this.position,
      hasCrossed: hasCrossed ?? this.hasCrossed,
    );
  }
}
