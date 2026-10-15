import 'package:flutter/material.dart';

import '../theme/kiuthi_theme.dart';

import '../storage/game_storage.dart';
import '../storage/settings_storage.dart';
import '../storage/statistics_storage.dart';
import 'home_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class KiuthiShell extends StatefulWidget {
  const KiuthiShell({
    super.key,
    required this.settings,
    required this.statistics,
    required this.games,
    required this.onSettingsChanged,
  });

  final SettingsStorage settings;
  final StatisticsStorage statistics;
  final GameStorage games;
  final VoidCallback onSettingsChanged;

  @override
  State<KiuthiShell> createState() => _KiuthiShellState();
}

class _KiuthiShellState extends State<KiuthiShell> {
  int _index = 0;

  static const _titles = ['Home', 'Statistics', 'Settings', 'How to Play'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(
              title: Text(_titles[_index]),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: KiuthiTheme.sandDeep),
              ),
            ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            settings: widget.settings,
            statistics: widget.statistics,
            games: widget.games,
            onReturn: () => setState(() {}),
          ),
          StatisticsScreen(statistics: widget.statistics),
          SettingsScreen(
            settings: widget.settings,
            onChanged: widget.onSettingsChanged,
          ),
          const HowToPlayScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: KiuthiTheme.card,
          border: Border(top: BorderSide(color: KiuthiTheme.sandDeep)),
        ),
        child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'How to Play',
          ),
        ],
        ),
      ),
    );
  }
}
