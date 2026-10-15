import 'package:flutter/material.dart';

import '../engine/game_controller.dart';
import '../engine/rule_config.dart';
import '../models/board_state.dart';
import '../storage/game_storage.dart';
import '../storage/settings_storage.dart';
import '../storage/statistics_storage.dart';
import '../theme/kiuthi_theme.dart';
import '../widgets/kiuthi_board.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.statistics,
    required this.games,
    required this.onReturn,
  });

  final SettingsStorage settings;
  final StatisticsStorage statistics;
  final GameStorage games;
  final VoidCallback onReturn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SavedGame? _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.games.load();
  }

  Future<void> _openGame(GameSession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(
          session: session,
          settings: widget.settings,
          statistics: widget.statistics,
          games: widget.games,
        ),
      ),
    );
    widget.onReturn();
    if (mounted) setState(() => _saved = widget.games.load());
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    return KiuthiPage(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Kiuthi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A Kikamba strategy game on a five-by-five line board. Play against the computer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.35, color: KiuthiTheme.muted),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 280, child: _OpeningBoard()),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final rules = RuleConfig.standard.copyWith(
                capturesCompulsory: widget.settings.compulsoryCaptures,
              );
              _openGame(
                GameSession.newGame(widget.settings.difficulty, rules: rules),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start playing'),
          ),
          if (saved != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                _openGame(
                  GameSession(
                    state: saved.state,
                    difficulty: saved.difficulty,
                    rules: saved.rules,
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: Text('Continue ${saved.difficulty.label} game'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpeningBoard extends StatelessWidget {
  const _OpeningBoard();

  @override
  Widget build(BuildContext context) {
    return KiuthiBoard(state: BoardState.initial(), legalMoves: const []);
  }
}
