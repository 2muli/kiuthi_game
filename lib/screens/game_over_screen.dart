import 'package:flutter/material.dart';

import '../models/board_state.dart';
import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../models/piece.dart';
import '../theme/kiuthi_theme.dart';

enum OverAction { again, changeDifficulty, home }

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.state,
    required this.difficulty,
  });

  final BoardState state;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game over')),
      body: KiuthiPage(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KiuthiPanel(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                child: Column(
                  children: [
                    Text(
                      resultHeadline(state.status),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resultDetail(state.endReason),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              KiuthiPanel(
                child: Column(
                  children: [
                    Text(
                      difficulty.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You captured ${state.redCaptured} · ${state.count(Player.red)} of your pieces remain',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Computer captured ${state.blueCaptured} · ${state.count(Player.blue)} blue pieces remain',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                provisionalEndingNote,
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.4, color: KiuthiTheme.muted),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context, OverAction.again),
                child: const Text('Play Again'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pop(context, OverAction.changeDifficulty),
                child: const Text('Change Difficulty'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, OverAction.home),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
