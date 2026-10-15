import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../storage/settings_storage.dart';
import '../theme/kiuthi_theme.dart';
import '../theme/piece_colors.dart';
import '../widgets/difficulty_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final SettingsStorage settings;
  final VoidCallback onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _save() async {
    await widget.settings.persist();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return KiuthiPage(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const KiuthiSectionLabel('Level'),
          const SizedBox(height: 8),
          DifficultySelector(
            selected: widget.settings.difficulty,
            onSelected: (Difficulty difficulty) async {
              setState(() => widget.settings.difficulty = difficulty);
              await _save();
            },
          ),
          const SizedBox(height: 16),
          KiuthiPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              subtitle: const Text('A short click when a piece moves.'),
              value: widget.settings.sound,
              onChanged: (value) async {
                setState(() => widget.settings.sound = value);
                await _save();
              },
            ),
          ),
          const SizedBox(height: 16),
          KiuthiPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KiuthiSectionLabel('Your pieces'),
                const SizedBox(height: 10),
                _ColorChoices(
                  colors: PieceColors.humanChoices,
                  selected: widget.settings.humanColor,
                  onSelected: (color) async {
                    setState(() => widget.settings.humanColor = color);
                    await _save();
                  },
                ),
                const SizedBox(height: 16),
                const KiuthiSectionLabel('Computer pieces'),
                const SizedBox(height: 10),
                _ColorChoices(
                  colors: PieceColors.computerChoices,
                  selected: widget.settings.computerColor,
                  onSelected: (color) async {
                    setState(() => widget.settings.computerColor = color);
                    await _save();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          KiuthiPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Require a capture when one is available'),
              subtitle: const Text(
                'Provisional rule, not confirmed tradition. Applies to the next game. Both sides follow it.',
              ),
              value: widget.settings.compulsoryCaptures,
              onChanged: (value) async {
                setState(() => widget.settings.compulsoryCaptures = value);
                await _save();
              },
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kiuthi does not use an account, a server, or an online opponent. Settings stay on this device.',
            style: TextStyle(height: 1.4, color: KiuthiTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _ColorChoices extends StatelessWidget {
  const _ColorChoices({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          _ColorDot(
            color: color,
            selected: color.toARGB32() == selected.toARGB32(),
            onTap: () => onSelected(color),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Piece color ${color.toARGB32().toRadixString(16)}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected ? KiuthiTheme.gold : Colors.white,
              width: selected ? 3.5 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
