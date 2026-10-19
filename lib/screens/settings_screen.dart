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
                  voice: 'Your',
                  colors: PieceColors.except(widget.settings.computerColor),
                  selected: widget.settings.humanColor,
                  blocked: widget.settings.computerColor,
                  onSelected: (color) async {
                    if (!widget.settings.assignHumanColor(color)) return;
                    setState(() {});
                    await _save();
                  },
                ),
                const SizedBox(height: 16),
                const KiuthiSectionLabel('Computer pieces'),
                const SizedBox(height: 10),
                _ColorChoices(
                  voice: 'Computer',
                  colors: PieceColors.except(widget.settings.humanColor),
                  selected: widget.settings.computerColor,
                  blocked: widget.settings.humanColor,
                  onSelected: (color) async {
                    if (!widget.settings.assignComputerColor(color)) return;
                    setState(() {});
                    await _save();
                  },
                ),
              ],
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
    required this.voice,
    required this.colors,
    required this.selected,
    required this.blocked,
    required this.onSelected,
  });

  final String voice;
  final List<Color> colors;
  final Color selected;
  final Color blocked;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          _ColorDot(
            voice: voice,
            color: color,
            selected: PieceColors.same(color, selected),
            blocked: PieceColors.same(color, blocked),
            onTap: () => onSelected(color),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.voice,
    required this.color,
    required this.selected,
    required this.blocked,
    required this.onTap,
  });

  final String voice;
  final Color color;
  final bool selected;
  final bool blocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hex = color.toARGB32().toRadixString(16);
    return Semantics(
      button: true,
      enabled: !blocked,
      selected: selected,
      label: blocked
          ? '$voice piece color $hex, already used'
          : '$voice piece color $hex',
      child: InkWell(
        onTap: blocked ? null : onTap,
        customBorder: const CircleBorder(),
        child: Opacity(
          opacity: blocked ? 0.35 : 1,
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
      ),
    );
  }
}
