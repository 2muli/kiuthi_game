import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../theme/kiuthi_theme.dart';
import 'board_piece.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.title,
    required this.detail,
    required this.mark,
    required this.active,
    required this.taken,
    required this.takenOwner,
  });

  final String title;
  final String detail;
  final Widget mark;
  final bool active;
  final int taken;
  final Player takenOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: KiuthiTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? KiuthiTheme.gold : KiuthiTheme.sandDeep,
          width: 2,
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
          taken == 0
              ? const SizedBox(height: 16, width: double.infinity)
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var index = 0; index < taken; index++)
                      BoardPiece(owner: takenOwner, diameter: 16),
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
          const SizedBox(height: 6),
          ExcludeSemantics(
            excluding: !active,
            child: Opacity(
              opacity: active ? 1 : 0,
              child: const DecoratedBox(
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
            ),
          ),
        ],
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  const StatusLine({super.key, required this.message});

  final String message;

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
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ),
      ),
    );
  }
}
