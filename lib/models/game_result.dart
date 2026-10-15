/// Live status of a game.
enum GameStatus { ongoing, redWins, blueWins, draw }

/// Why a finished game ended.
///
/// These endings are provisional development rules. They are not labelled
/// as confirmed traditional Kiuthi.
enum EndReason { none, eliminated, immobilized, repetition }

class GameResult {
  const GameResult({required this.status, required this.reason});

  final GameStatus status;
  final EndReason reason;

  static const ongoing = GameResult(
    status: GameStatus.ongoing,
    reason: EndReason.none,
  );

  bool get isOver => status != GameStatus.ongoing;
}

const String provisionalEndingNote =
    'This ending is a provisional development rule so the game can be '
    'finished offline. It is not confirmed traditional Kiuthi.';

String resultHeadline(GameStatus status) {
  switch (status) {
    case GameStatus.redWins:
      return 'You win';
    case GameStatus.blueWins:
      return 'Computer wins';
    case GameStatus.draw:
      return 'Draw';
    case GameStatus.ongoing:
      return 'In progress';
  }
}

String resultDetail(EndReason reason) {
  switch (reason) {
    case EndReason.eliminated:
      return 'One side has no pieces left.';
    case EndReason.immobilized:
      return 'The side to move has no legal move.';
    case EndReason.repetition:
      return 'The same position occurred three times.';
    case EndReason.none:
      return '';
  }
}
