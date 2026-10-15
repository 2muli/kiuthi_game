import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/engine/game_controller.dart';
import 'package:kiuthi_game/engine/rule_config.dart';
import 'package:kiuthi_game/models/board_state.dart';
import 'package:kiuthi_game/models/difficulty.dart';
import 'package:kiuthi_game/models/game_result.dart';
import 'package:kiuthi_game/models/piece.dart';
import 'package:kiuthi_game/storage/game_storage.dart';
import 'package:kiuthi_game/storage/key_value_store.dart';
import 'package:kiuthi_game/storage/settings_storage.dart';
import 'package:kiuthi_game/storage/statistics_storage.dart';

void main() {
  test('settings and statistics round-trip in local storage', () async {
    final store = MemoryStore();
    final settings = SettingsStorage(store)
      ..difficulty = Difficulty.expert
      ..sound = false
      ..compulsoryCaptures = true
      ..humanColor = const Color(0xFF2E7D32)
      ..computerColor = const Color(0xFF283593);
    await settings.persist();

    final loaded = SettingsStorage(store)..load();
    expect(loaded.difficulty, Difficulty.expert);
    expect(loaded.sound, isFalse);
    expect(loaded.compulsoryCaptures, isTrue);
    expect(loaded.humanColor.toARGB32(), const Color(0xFF2E7D32).toARGB32());
    expect(
      loaded.computerColor.toARGB32(),
      const Color(0xFF283593).toARGB32(),
    );

    final stats = StatisticsStorage(store);
    stats.record(
      difficulty: Difficulty.expert,
      status: GameStatus.redWins,
      reason: EndReason.eliminated,
      humanCaptured: 10,
      computerCaptured: 2,
      humanLeft: 8,
      computerLeft: 0,
    );
    stats.record(
      difficulty: Difficulty.easy,
      status: GameStatus.draw,
      reason: EndReason.repetition,
      humanCaptured: 4,
      computerCaptured: 4,
      humanLeft: 6,
      computerLeft: 6,
    );
    await stats.persist();

    final again = StatisticsStorage(store)..load();
    expect(again.wins, 1);
    expect(again.draws, 1);
    expect(again.records[Difficulty.expert]!.wins, 1);
    expect(again.records[Difficulty.easy]!.draws, 1);
    expect(again.last?.status, GameStatus.draw);
    expect(again.last?.difficulty, Difficulty.easy);
    expect(again.last?.humanCaptured, 4);
  });

  test(
    'a saved game restores crossing, the chain, and rejects corrupt data',
    () async {
      final start =
          (PositionSetup()
                ..put(Player.red, 4, 2, crossed: true)
                ..put(Player.blue, 3, 2)
                ..put(Player.blue, 1, 2))
              .build();
      final session = GameSession(
        state: start,
        difficulty: Difficulty.intermediate,
        rules: const RuleConfig(capturesCompulsory: true),
      );
      final jump = session.legalMoves.firstWhere((move) => move.to.row == 2);
      session.applyHumanMove(jump);

      final store = MemoryStore();
      final games = GameStorage(store);
      await games.save(
        SavedGame(
          difficulty: Difficulty.intermediate,
          compulsoryCaptures: true,
          state: session.state,
        ),
      );

      final saved = games.load();
      expect(saved, isNotNull);
      expect(saved!.difficulty, Difficulty.intermediate);
      expect(saved.compulsoryCaptures, isTrue);
      expect(saved.state.chainPieceId, session.state.chainPieceId);
      expect(
        saved.state.pieceById(saved.state.chainPieceId!)!.hasCrossed,
        isTrue,
      );
      expect(saved.state.count(Player.blue), 1);
      expect(saved.state.positionKey, session.state.positionKey);

      await store.setString(GameStorage.storageKey, '{not json');
      expect(games.load(), isNull);

      await store.setString(
        GameStorage.storageKey,
        '{"v":1,"difficulty":"nope"}',
      );
      expect(games.load(), isNull);
    },
  );

  test('finished and inconsistent payloads are refused', () {
    final state = BoardState.initial();
    final json = state.toJson();
    expect(BoardState.fromJson(json)!.positionKey, state.positionKey);

    json['cells'] = List<Object?>.filled(24, null);
    expect(BoardState.fromJson(json), isNull);

    final broken = BoardState.initial().toJson();
    broken['redCaptured'] = 4;
    expect(BoardState.fromJson(broken), isNull);
  });
}
