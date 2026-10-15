import '../engine/rule_config.dart';
import '../models/board_state.dart';
import '../models/move.dart';
import 'alpha_beta.dart';
import 'difficulty_config.dart';
import 'transposition_table.dart';

/// Entry point for the stronger difficulties.
///
/// The search itself is alpha-beta minimax in [AlphaBetaSearch]. This wrapper
/// is what tests and the player call, so both names in the specification
/// stay attached to the same legal-move generator.
class Minimax {
  Minimax._();

  static MoveSequence choose({
    required BoardState state,
    required List<MoveSequence> sequences,
    required RuleConfig rules,
    required DifficultyConfig config,
  }) {
    final search = AlphaBetaSearch(
      rules: rules,
      config: config,
      deadline: DateTime.now().add(config.budget),
      table: TranspositionTable(),
    );
    return search.choose(state, sequences);
  }
}
