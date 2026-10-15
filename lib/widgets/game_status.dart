import 'package:flutter/material.dart';

import '../theme/kiuthi_theme.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.title,
    required this.detail,
    required this.mark,
    required this.active,
  });

  final String title;
  final String detail;
  final Widget mark;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: KiuthiTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? KiuthiTheme.gold : KiuthiTheme.sandDeep,
          width: active ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: active ? const Color(0x33E6A817) : const Color(0x12000000),
            blurRadius: active ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              mark,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              color: KiuthiTheme.muted,
            ),
          ),
          if (active) ...[
            const SizedBox(height: 6),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFF3D0),
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  'To move',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: KiuthiTheme.clay,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  const StatusLine({super.key, required this.message, this.busy = false});

  final String message;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KiuthiTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiuthiTheme.sandDeep),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3),
            ),
            if (busy) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(
                minHeight: 3,
                color: KiuthiTheme.clay,
                backgroundColor: KiuthiTheme.sandDeep,
                borderRadius: BorderRadius.all(Radius.circular(99)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
