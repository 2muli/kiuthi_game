import 'package:flutter/material.dart';

import 'screens/shell_screen.dart';
import 'storage/game_storage.dart';
import 'storage/settings_storage.dart';
import 'storage/statistics_storage.dart';
import 'theme/kiuthi_theme.dart';
import 'theme/piece_colors.dart';

class KiuthiApp extends StatefulWidget {
  const KiuthiApp({
    super.key,
    required this.settings,
    required this.statistics,
    required this.games,
  });

  final SettingsStorage settings;
  final StatisticsStorage statistics;
  final GameStorage games;

  @override
  State<KiuthiApp> createState() => _KiuthiAppState();
}

class _KiuthiAppState extends State<KiuthiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiuthi',
      debugShowCheckedModeBanner: false,
      theme: KiuthiTheme.theme(),
      builder: (context, child) {
        return PieceColors(
          human: widget.settings.humanColor,
          computer: widget.settings.computerColor,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: KiuthiShell(
        settings: widget.settings,
        statistics: widget.statistics,
        games: widget.games,
        onSettingsChanged: () => setState(() {}),
      ),
    );
  }
}
