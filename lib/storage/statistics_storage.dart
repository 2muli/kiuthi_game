import 'dart:convert';

import '../models/difficulty.dart';
import '../models/game_result.dart';
import 'key_value_store.dart';

class DifficultyRecord {
  int played = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;

  Map<String, int> toJson() => {
    'played': played,
    'wins': wins,
    'losses': losses,
    'draws': draws,
  };

  void loadJson(Object? raw) {
    if (raw is! Map) return;
    played = _int(raw['played']);
    wins = _int(raw['wins']);
    losses = _int(raw['losses']);
    draws = _int(raw['draws']);
  }
}

int _int(Object? value) => value is int && value >= 0 ? value : 0;

class LastGame {
  const LastGame({
    required this.difficulty,
    required this.status,
    required this.reason,
    required this.humanCaptured,
    required this.computerCaptured,
    required this.humanLeft,
    required this.computerLeft,
  });

  final Difficulty difficulty;
  final GameStatus status;
  final EndReason reason;
  final int humanCaptured;
  final int computerCaptured;
  final int humanLeft;
  final int computerLeft;

  Map<String, Object> toJson() => {
    'difficulty': difficulty.name,
    'status': status.name,
    'reason': reason.name,
    'humanCaptured': humanCaptured,
    'computerCaptured': computerCaptured,
    'humanLeft': humanLeft,
    'computerLeft': computerLeft,
  };

  static LastGame? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final difficulty = Difficulty.values.where(
      (item) => item.name == raw['difficulty'],
    );
    final status = GameStatus.values.where((item) => item.name == raw['status']);
    final reason = EndReason.values.where((item) => item.name == raw['reason']);
    if (difficulty.isEmpty || status.isEmpty || reason.isEmpty) return null;
    if (status.first == GameStatus.ongoing) return null;
    return LastGame(
      difficulty: difficulty.first,
      status: status.first,
      reason: reason.first,
      humanCaptured: _int(raw['humanCaptured']),
      computerCaptured: _int(raw['computerCaptured']),
      humanLeft: _int(raw['humanLeft']),
      computerLeft: _int(raw['computerLeft']),
    );
  }
}

class StatisticsStorage {
  StatisticsStorage(this._store);

  final KeyValueStore _store;
  static const storageKey = 'kiuthi_statistics';

  final Map<Difficulty, DifficultyRecord> records = {
    for (final difficulty in Difficulty.values) difficulty: DifficultyRecord(),
  };
  LastGame? last;

  int get played =>
      records.values.fold(0, (sum, record) => sum + record.played);
  int get wins => records.values.fold(0, (sum, record) => sum + record.wins);
  int get losses =>
      records.values.fold(0, (sum, record) => sum + record.losses);
  int get draws => records.values.fold(0, (sum, record) => sum + record.draws);

  void load() {
    final raw = _store.getString(storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final difficulty in Difficulty.values) {
        records[difficulty]!.loadJson(decoded[difficulty.name]);
      }
      last = LastGame.fromJson(decoded['last']);
    } catch (_) {
      reset(persistAfter: false);
    }
  }

  void record({
    required Difficulty difficulty,
    required GameStatus status,
    required EndReason reason,
    required int humanCaptured,
    required int computerCaptured,
    required int humanLeft,
    required int computerLeft,
  }) {
    final record = records[difficulty]!;
    switch (status) {
      case GameStatus.redWins:
        record.played += 1;
        record.wins += 1;
      case GameStatus.blueWins:
        record.played += 1;
        record.losses += 1;
      case GameStatus.draw:
        record.played += 1;
        record.draws += 1;
      case GameStatus.ongoing:
        return;
    }
    last = LastGame(
      difficulty: difficulty,
      status: status,
      reason: reason,
      humanCaptured: humanCaptured,
      computerCaptured: computerCaptured,
      humanLeft: humanLeft,
      computerLeft: computerLeft,
    );
  }

  void reset({bool persistAfter = true}) {
    for (final record in records.values) {
      record.played = 0;
      record.wins = 0;
      record.losses = 0;
      record.draws = 0;
    }
    last = null;
    if (persistAfter) {
      persist();
    }
  }

  Future<void> persist() {
    final encoded = jsonEncode({
      for (final difficulty in Difficulty.values)
        difficulty.name: records[difficulty]!.toJson(),
      if (last != null) 'last': last!.toJson(),
    });
    return _store.setString(storageKey, encoded);
  }
}
