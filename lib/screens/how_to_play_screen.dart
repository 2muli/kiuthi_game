import 'package:flutter/material.dart';

import '../engine/rule_config.dart';
import '../models/board_state.dart';
import '../models/piece.dart';
import '../theme/kiuthi_theme.dart';
import '../widgets/board_piece.dart';
import '../widgets/kiuthi_board.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final capture = PositionSetup()
      ..put(Player.blue, 1, 2)
      ..put(Player.red, 3, 2);
    return KiuthiPage(
      safeBottom: false,
      child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _Section(
              title: 'The board',
              body: 'Kiuthi is played on 25 intersections. Pieces move only along the drawn lines: one step horizontally, vertically, or diagonally to an empty neighbouring point. The lines in this app are the board layout used for every rule and for the computer.',
            ),
            SizedBox(
              height: 240,
              child: KiuthiBoard(
                state: BoardState.initial(),
                legalMoves: const [],
              ),
            ),
            const _Section(
              title: 'The pieces',
              body: 'You play Red, from the bottom two rows. The computer plays Blue, from the top two rows. Each side starts with ten pieces. The middle row is empty. A selected piece has a gold ring and a notch, not colour alone.',
            ),
            const KiuthiPanel(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Legend(owner: Player.red, label: 'You'),
                  _Legend(owner: Player.blue, label: 'Computer'),
                ],
              ),
            ),
            const _Section(
              title: 'Ordinary movement',
              body: 'On your turn, tap one of your pieces. Legal destinations are marked. Tap a green circle to move there. A quiet move goes exactly one point, and only onto an empty point.',
            ),
            const _Section(
              title: 'Captures',
              body: 'Jump in a straight line over a neighbouring opponent onto the empty point just beyond, along the lines. The jumped piece is removed. An orange circle marks a capture.',
            ),
            SizedBox(
              height: 220,
              child: KiuthiBoard(state: capture.build(), legalMoves: const []),
            ),
            const Text(
              'Here Red can jump straight up over Blue, landing on the empty point beyond.',
              style: TextStyle(height: 1.35),
            ),
            const _Section(
              title: 'Consecutive captures',
              body: 'If the same piece can jump again from where it landed, the turn continues. You choose when more than one jump is available. A single continuation is played for you. The computer does not move until the chain is finished.',
            ),
            const _Section(
              title: 'The edge line',
              body: 'Until a piece reaches the other side\'s last line, that piece can move sideways or forward, but not backward. Your last line is the top row, at the computer\'s end. The computer\'s last line is the bottom row, at your end. Only that piece, after it has landed on that line, may move back. A piece may still slide along the row it is already on.',
            ),
            const _Section(
              title: 'How a game can end',
              body: 'Three endings are in use so a game can finish. They are provisional development rules, not confirmed traditional Kiuthi: a side with no pieces left loses; a side that has pieces but no legal move loses; the same position three times is a draw.',
            ),
            const _Section(
              title: 'Difficulty',
              body: 'Easy, Intermediate, and Expert use the same board and the same rules. Easy picks among good legal moves with a short lookahead. Intermediate and Expert search ahead with minimax and alpha-beta pruning. Expert searches deeper, within a time limit, so the app stays responsive.',
            ),
            const _Section(
              title: 'Undo',
              body: 'Undo takes back your latest turn and the computer\'s reply. It does not undo one jump in the middle of a chain.',
            ),
            const SizedBox(height: 14),
            KiuthiPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assumptions still open',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (final note in assumptionNotes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '• $note',
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.owner, required this.label});

  final Player owner;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        BoardPiece(owner: owner, diameter: 42),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: KiuthiPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
