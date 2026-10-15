import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../theme/kiuthi_theme.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final Difficulty selected;
  final ValueChanged<Difficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final difficulty in Difficulty.values) ...[
          _DifficultyCard(
            difficulty: difficulty,
            selected: difficulty == selected,
            onTap: () => onSelected(difficulty),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? KiuthiTheme.clay : KiuthiTheme.card,
      elevation: selected ? 2 : 0,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? KiuthiTheme.clay : KiuthiTheme.sandDeep,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Colors.white : KiuthiTheme.clay,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: selected ? Colors.white : KiuthiTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficulty.description,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFFFF3E0)
                            : KiuthiTheme.ink,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
