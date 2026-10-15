import '../models/board_state.dart';
import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import 'game_result_checker.dart';
import 'move_generator.dart';
import 'move_validator.dart';
import 'rule_config.dart';
import 'rule_engine.dart';

/// Rejects a computer move that was computed for a different position,
/// including after restart or undo.
class SearchGuard {
  int _token = 0;

  int start() => ++_token;

  void invalidate() => _token++;

  bool accepts(int token) => token == _token;
}

/// Human-versus-computer session. Pure Dart: no widgets.
///
/// Undo restores the position before the latest human turn. If the computer
/// has already replied, that reply is removed as well. A capture chain is
/// one turn, so undo never rewinds a single jump inside it.
class GameSession {
  GameSession({
    required this.state,
    required this.difficulty,
    RuleConfig? rules,
  }) : rules = rules ?? RuleConfig.standard;

  factory GameSession.newGame(Difficulty difficulty, {RuleConfig? rules}) {
    return GameSession(
      state: BoardState.initial(),
      difficulty: difficulty,
      rules: rules,
    );
  }

  BoardState state;
  final Difficulty difficulty;
  final RuleConfig rules;
  final SearchGuard guard = SearchGuard();
  final List<BoardState> undoStack = [];
  bool _snapshotOpen = false;

  List<Move> get legalMoves => MoveGenerator.immediate(state, rules);

  bool get canUndo => undoStack.isNotEmpty;

  void restart() {
    guard.invalidate();
    state = BoardState.initial();
    undoStack.clear();
    _snapshotOpen = false;
  }

  /// Restores the position before the current human turn and the computer
  /// reply, if one has been played. Returns false when there is nothing
  /// to undo. Also invalidates an in-flight computer search.
  bool undo() {
    guard.invalidate();
    if (undoStack.isEmpty) return false;
    state = undoStack.removeLast();
    _snapshotOpen = false;
    return true;
  }

  bool applyHumanMove(Move move) {
    if (state.status != GameStatus.ongoing) return false;
    if (state.activePlayer != Player.red) return false;
    if (!MoveValidator.isLegal(state, move, rules)) return false;
    if (!_snapshotOpen) {
      undoStack.add(state);
      _snapshotOpen = true;
    }
    state = GameFlow.applyStep(state, move, rules);
    if (state.chainPieceId == null) _snapshotOpen = false;
    return true;
  }

  /// One computer step. Used so the board can animate a chain jump by jump.
  /// Does not record an undo snapshot.
  bool applyComputerStep(Move move) {
    if (state.status != GameStatus.ongoing) return false;
    if (state.activePlayer != Player.blue) return false;
    if (!MoveValidator.isLegal(state, move, rules)) return false;
    state = GameFlow.applyStep(state, move, rules);
    return true;
  }

  /// Applies a whole computer turn that was checked against [stateKey].
  /// A mismatch means the search belongs to an older position.
  bool applyComputerSequence(List<Move> moves, {required String stateKey}) {
    if (state.positionKey != stateKey) return false;
    if (state.status != GameStatus.ongoing) return false;
    if (state.activePlayer != Player.blue) return false;
    if (moves.isEmpty) return false;
    var cursor = state;
    for (final move in moves) {
      if (!MoveValidator.isLegal(cursor, move, rules)) return false;
      cursor = GameFlow.applyStep(cursor, move, rules);
    }
    if (cursor.chainPieceId != null) return false;
    state = cursor;
    return true;
  }

  /// When the side to move has no legal move, record the provisional loss.
  /// Does nothing when a legal move still exists.
  bool adjudicateIfNoMove() {
    if (state.status != GameStatus.ongoing) return false;
    final judged = GameResultChecker.judge(state, rules);
    if (!judged.isOver) return false;
    state = state.copyWith(status: judged.status, endReason: judged.reason);
    return true;
  }
}

/// Shared step logic so the session, tests, and search see one transition.
class GameFlow {
  GameFlow._();

  static BoardState applyStep(BoardState state, Move move, RuleConfig rules) {
    final next = RuleEngine.apply(state, move, rules);
    if (next.chainPieceId != null) return next;

    final judged = GameResultChecker.judge(next, rules);
    final history = [...state.positionHistory, next.positionKey];
    var status = judged.status;
    var reason = judged.reason;
    if (status == GameStatus.ongoing &&
        rules.drawByRepetition &&
        history.where((key) => key == next.positionKey).length >= 3) {
      status = GameStatus.draw;
      reason = EndReason.repetition;
    }
    return next.copyWith(
      status: status,
      endReason: reason,
      positionHistory: history,
    );
  }
}
