import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'storage/game_storage.dart';
import 'storage/key_value_store.dart';
import 'storage/settings_storage.dart';
import 'storage/statistics_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = PrefsStore(preferences);
  final settings = SettingsStorage(store)..load();
  final statistics = StatisticsStorage(store)..load();
  final games = GameStorage(store);
  runApp(KiuthiApp(settings: settings, statistics: statistics, games: games));
}
