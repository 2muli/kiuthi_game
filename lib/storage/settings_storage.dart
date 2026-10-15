import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../theme/kiuthi_theme.dart';
import 'key_value_store.dart';

class SettingsStorage {
  SettingsStorage(this._store);

  final KeyValueStore _store;

  static const difficultyKey = 'kiuthi_difficulty';
  static const soundKey = 'kiuthi_sound';
  static const compulsoryKey = 'kiuthi_compulsory';
  static const humanColorKey = 'kiuthi_human_color';
  static const computerColorKey = 'kiuthi_computer_color';

  Difficulty difficulty = Difficulty.easy;
  bool sound = true;
  bool compulsoryCaptures = false;
  Color humanColor = KiuthiTheme.redPiece;
  Color computerColor = KiuthiTheme.bluePiece;

  void load() {
    difficulty = Difficulty.parse(_store.getString(difficultyKey));
    final soundRaw = _store.getString(soundKey);
    sound = soundRaw != '0';
    compulsoryCaptures = _store.getString(compulsoryKey) == '1';
    humanColor = _readColor(humanColorKey, KiuthiTheme.redPiece);
    computerColor = _readColor(computerColorKey, KiuthiTheme.bluePiece);
  }

  Color _readColor(String key, Color fallback) {
    final parsed = int.tryParse(_store.getString(key) ?? '');
    if (parsed == null) return fallback;
    return Color(parsed);
  }

  Future<void> persist() async {
    await _store.setString(difficultyKey, difficulty.name);
    await _store.setString(soundKey, sound ? '1' : '0');
    await _store.setString(compulsoryKey, compulsoryCaptures ? '1' : '0');
    await _store.setString(humanColorKey, humanColor.toARGB32().toString());
    await _store.setString(
      computerColorKey,
      computerColor.toARGB32().toString(),
    );
  }
}
