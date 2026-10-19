/// Switches for rules the specification says must not be invented as
/// historical fact. Defaults are development assumptions, documented in
/// [assumptionNotes], and can be changed without rewriting the board UI.
class RuleConfig {
  const RuleConfig({
    this.capturesCompulsory = false,
    this.allowDirectionChangeBetweenJumps = true,
    this.winByElimination = true,
    this.winByImmobilization = true,
    this.drawByRepetition = true,
    this.mayEnterOpponentEdge = true,
  });

  /// When true, a quiet move is illegal if any capture exists.
  /// Default false: starting a capture is optional.
  final bool capturesCompulsory;

  /// A single jump is always straight. This flag controls whether the
  /// next jump in the same chain may leave in a new direction.
  /// Default true.
  final bool allowDirectionChangeBetweenJumps;

  /// Provisional: capturing every opposing piece wins.
  final bool winByElimination;

  /// Provisional: a player who has pieces but no legal move loses.
  final bool winByImmobilization;

  /// Provisional: the same position three times is a draw.
  final bool drawByRepetition;

  /// A piece may land on the opponent's home edge. Default true.
  final bool mayEnterOpponentEdge;

  static const standard = RuleConfig();

  RuleConfig copyWith({bool? capturesCompulsory}) {
    return RuleConfig(
      capturesCompulsory: capturesCompulsory ?? this.capturesCompulsory,
      allowDirectionChangeBetweenJumps: allowDirectionChangeBetweenJumps,
      winByElimination: winByElimination,
      winByImmobilization: winByImmobilization,
      drawByRepetition: drawByRepetition,
      mayEnterOpponentEdge: mayEnterOpponentEdge,
    );
  }
}

/// Human-readable record of choices that are not confirmed tradition.
const List<String> assumptionNotes = [
  'No board diagram was included with the specification. Until one is confirmed, every intersection connects to its neighbours one step away horizontally, vertically, and on both diagonals. That graph lives only in the board layout.',
  'Until a piece lands on the opponent\'s last line, that piece may move sideways or forward only. Red\'s last line is the top row. Blue\'s last line is the bottom row. Reaching it is remembered for that piece alone, and only then may that piece move backward.',
  'Sliding along the row a piece already occupies is allowed. A backward step, including a backward jump, is blocked until that piece has reached the far line.',
  'Each jump is a straight two-step along connected points. A later jump in the same turn may change direction.',
  'Starting a capture is optional. A quiet move stays legal even when a capture exists. After a capture begins, that piece must keep jumping while another jump is legal, and the player chooses each jump, including when only one remains.',
  'A piece may enter and remain on the opponent\'s edge. There is no promotion.',
  'Red moves first. There is no extra restriction on the first move.',
  'The game can end, provisionally, when a side has no pieces, when the side to move has no legal move, or when the same position occurs three times. These endings are labelled provisional in the app.',
];
