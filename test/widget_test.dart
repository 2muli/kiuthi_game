import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiuthi_game/app.dart';
import 'package:kiuthi_game/storage/game_storage.dart';
import 'package:kiuthi_game/storage/key_value_store.dart';
import 'package:kiuthi_game/storage/settings_storage.dart';
import 'package:kiuthi_game/storage/statistics_storage.dart';

void main() {
  Future<void> useTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('home explains the difficulties and starts a local game', (
    tester,
  ) async {
    await useTallSurface(tester);
    final store = MemoryStore();
    final settings = SettingsStorage(store)..load();
    final statistics = StatisticsStorage(store)..load();
    await tester.pumpWidget(
      KiuthiApp(
        settings: settings,
        statistics: statistics,
        games: GameStorage(store),
      ),
    );

    expect(find.text('Kiuthi'), findsOneWidget);
    expect(find.text('Start playing'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Your pieces'), findsOneWidget);
    expect(find.text('Computer pieces'), findsOneWidget);
    expect(
      find.text('A friendly challenge for learning Kiuthi.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Last game'), findsOneWidget);
    expect(find.text('No finished games yet.'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start playing'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Your turn'), findsOneWidget);
    expect(find.text('Computer · Blue'), findsOneWidget);
    expect(find.text('You · Red'), findsOneWidget);
    expect(find.textContaining('Kiuthi · Easy'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Row 4, column 1, your piece').last);
    await tester.pump();

    expect(find.textContaining('Gold marks your piece'), findsOneWidget);

    await tester.tap(
      find.bySemanticsLabel('Row 1, column 1, computer piece').last,
    );
    await tester.pump();
    expect(find.text("That is the computer's piece."), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Row 3, column 3, empty').last);
    await tester.pump();
    expect(find.text('That move is not legal.'), findsOneWidget);
  });

  testWidgets('a legal move is played and the computer answers', (tester) async {
    await useTallSurface(tester);
    final store = MemoryStore();
    await tester.pumpWidget(
      KiuthiApp(
        settings: SettingsStorage(store)..load(),
        statistics: StatisticsStorage(store)..load(),
        games: GameStorage(store),
      ),
    );
    await tester.tap(find.text('Start playing'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsLabel('Row 4, column 1, your piece').last,
    );
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Row 3, column 1, empty').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.bySemanticsLabel('Row 3, column 1, your piece'),
      findsOneWidget,
    );

    var answered = false;
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.textContaining('Your turn').evaluate().isNotEmpty) {
        answered = true;
        break;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
    }
    expect(answered, isTrue);
  });

  testWidgets('How to Play shows the edge rule and the provisional ending', (
    tester,
  ) async {
    await useTallSurface(tester);
    final store = MemoryStore();
    await tester.pumpWidget(
      KiuthiApp(
        settings: SettingsStorage(store)..load(),
        statistics: StatisticsStorage(store)..load(),
        games: GameStorage(store),
      ),
    );
    await tester.tap(find.text('How to Play'));
    await tester.pumpAndSettle();
    expect(find.text('The board'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('The edge line'), 300);
    expect(
      find.textContaining('but not backward'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.textContaining('provisional development rules'),
      300,
    );
    expect(
      find.textContaining('provisional development rules'),
      findsOneWidget,
    );
  });
}
