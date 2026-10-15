import '../models/difficulty.dart';
import 'position_evaluator.dart';

/// How each difficulty chooses among legal moves.
///
/// The board, the rules, and move generation stay the same. Only search
/// method, depth, time, variation, and evaluation weights change.
class DifficultyConfig {
  const DifficultyConfig({
    required this.difficulty,
    required this.useMinimax,
    required this.depth,
    required this.iterative,
    required this.budget,
    required this.variation,
    required this.weights,
  });

  final Difficulty difficulty;

  /// Easy uses a one-move heuristic. Stronger levels search with minimax.
  final bool useMinimax;

  /// Fixed depth for Intermediate. Maximum depth for Expert.
  final int depth;
  final bool iterative;
  final Duration budget;

  /// Easy may pick any legal move within this many points of the best.
  /// Zero means always take the best score.
  final double variation;
  final EvalWeights weights;

  static DifficultyConfig of(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const DifficultyConfig(
          difficulty: Difficulty.easy,
          useMinimax: false,
          depth: 1,
          iterative: false,
          budget: Duration(milliseconds: 200),
          variation: 15,
          weights: EvalWeights.easy,
        );
      case Difficulty.intermediate:
        return const DifficultyConfig(
          difficulty: Difficulty.intermediate,
          useMinimax: true,
          depth: 3,
          iterative: false,
          budget: Duration(milliseconds: 450),
          variation: 0,
          weights: EvalWeights.intermediate,
        );
      case Difficulty.expert:
        return const DifficultyConfig(
          difficulty: Difficulty.expert,
          useMinimax: true,
          depth: 5,
          iterative: true,
          budget: Duration(milliseconds: 700),
          variation: 0,
          weights: EvalWeights.expert,
        );
    }
  }
}
