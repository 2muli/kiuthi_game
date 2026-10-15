import 'dart:convert';

import '../engine/rule_config.dart';
import '../models/board_state.dart';
import '../models/difficulty.dart';
import '../models/game_result.dart';

import 'key_value_store.dart';

class SavedGame {
  const SavedGame({
    required this.difficulty,
    required this.compulsoryCaptures,
    required this.state,
  });

  final Difficulty difficulty;
  final bool compulsoryCaptures;
  final BoardState state;

  RuleConfig get rules =>
      RuleConfig.standard.copyWith(capturesCompulsory: compulsoryCaptures);
}

/// Saves one game in progress. Undo history is not stored: after the app
/// is closed, resume restores the position, the side to move, crossing
/// flags, and a capture chain, but not earlier turns.
class GameStorage {
  GameStorage(this._store);

  final KeyValueStore _store;
  static const storageKey = 'kiuthi_saved_game';

  SavedGame? load() {
    final raw = _store.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['v'] != 1) return null;
      final state = BoardState.fromJson(decoded['state']);
      if (state == null || state.status != GameStatus.ongoing) return null;
      final compulsory = decoded['compulsory'];
      final difficultyName = decoded['difficulty'];
      if (compulsory is! bool || difficultyName is! String) return null;
      final known = Difficulty.values.where(
        (item) => item.name == difficultyName,
      );
      if (known.isEmpty) return null;
      return SavedGame(
        difficulty: known.first,
        compulsoryCaptures: compulsory,
        state: state,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(SavedGame game) {
    if (game.state.status != GameStatus.ongoing) return clear();
    final encoded = jsonEncode({
      'v': 1,
      'difficulty': game.difficulty.name,
      'compulsory': game.compulsoryCaptures,
      'state': game.state.toJson(),
    });
    return _store.setString(storageKey, encoded);
  }

  Future<void> clear() => _store.remove(storageKey);
}
