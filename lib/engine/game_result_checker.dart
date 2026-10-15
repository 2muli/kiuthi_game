import '../models/board_state.dart';
import '../models/game_result.dart';
import '../models/piece.dart';
import 'move_generator.dart';
import 'rule_config.dart';

/// Provisional endings. Callers must keep the wording labelled provisional.
class GameResultChecker {
  GameResultChecker._();

  static GameResult judge(BoardState state, RuleConfig rules) {
    if (state.chainPieceId != null) return GameResult.ongoing;

    final red = state.count(Player.red);
    final blue = state.count(Player.blue);
    if (rules.winByElimination) {
      if (red == 0 && blue == 0) {
        return const GameResult(
          status: GameStatus.draw,
          reason: EndReason.eliminated,
        );
      }
      if (red == 0) {
        return const GameResult(
          status: GameStatus.blueWins,
          reason: EndReason.eliminated,
        );
      }
      if (blue == 0) {
        return const GameResult(
          status: GameStatus.redWins,
          reason: EndReason.eliminated,
        );
      }
    }

    if (rules.winByImmobilization &&
        MoveGenerator.immediate(state, rules).isEmpty) {
      final winner = state.activePlayer == Player.red
          ? GameStatus.blueWins
          : GameStatus.redWins;
      return GameResult(status: winner, reason: EndReason.immobilized);
    }

    return GameResult.ongoing;
  }
}
