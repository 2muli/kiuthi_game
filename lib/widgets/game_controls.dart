import 'package:flutter/material.dart';

import '../theme/kiuthi_theme.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    super.key,
    required this.onUndo,
    required this.onRestart,
    required this.onHome,
    required this.undoEnabled,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;
  final bool undoEnabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KiuthiTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KiuthiTheme.sandDeep),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: _Control(
                icon: Icons.undo_rounded,
                label: 'Undo',
                onPressed: undoEnabled ? onUndo : null,
              ),
            ),
            Expanded(
              child: _Control(
                icon: Icons.refresh_rounded,
                label: 'Restart',
                onPressed: onRestart,
              ),
            ),
            Expanded(
              child: _Control(
                icon: Icons.home_outlined,
                label: 'Home',
                onPressed: onHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: KiuthiTheme.ink,
        disabledForegroundColor: KiuthiTheme.muted.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

Future<bool> confirmDiscard(BuildContext context, String title) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: const Text('The game in progress will be discarded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      );
    },
  );
  return answer ?? false;
}
