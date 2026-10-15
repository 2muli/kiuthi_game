import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/game_result.dart';
import '../storage/statistics_storage.dart';
import '../theme/kiuthi_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.statistics});

  final StatisticsStorage statistics;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = widget.statistics;
    final last = stats.last;
    return KiuthiPage(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const KiuthiSectionLabel('Last game'),
          const SizedBox(height: 8),
          if (last == null)
            const KiuthiPanel(
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty_rounded, color: KiuthiTheme.clay),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No finished games yet.',
                      style: TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ),
                ],
              ),
            )
          else
            KiuthiPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resultHeadline(last.status),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(resultDetail(last.reason)),
                  const SizedBox(height: 10),
                  Text(
                    'Level: ${last.difficulty.label}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You captured ${last.humanCaptured} · ${last.humanLeft} of your pieces left',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Computer captured ${last.computerCaptured} · ${last.computerLeft} blue pieces left',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    provisionalEndingNote,
                    style: TextStyle(height: 1.35, color: KiuthiTheme.muted),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Text(
            stats.played == 0
                ? 'Totals'
                : '${stats.wins} wins · ${stats.losses} losses · ${stats.draws} draws',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Wins are games you finished ahead.',
            style: TextStyle(height: 1.35),
          ),
          const SizedBox(height: 12),
          for (final difficulty in Difficulty.values)
            _RecordCard(
              difficulty: difficulty,
              record: stats.records[difficulty]!,
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: stats.played == 0
                ? null
                : () async {
                    stats.reset();
                    await stats.persist();
                    if (mounted) setState(() {});
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: KiuthiTheme.ink,
              side: const BorderSide(color: KiuthiTheme.woodEdge),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Clear statistics'),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.difficulty, required this.record});

  final Difficulty difficulty;
  final DifficultyRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KiuthiPanel(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              difficulty.label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${record.played} played · ${record.wins} wins · ${record.losses} losses · ${record.draws} draws',
              style: const TextStyle(color: KiuthiTheme.muted, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
