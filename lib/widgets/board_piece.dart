import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../theme/kiuthi_theme.dart';
import '../theme/piece_colors.dart';

/// A stone. Red carries a ring and Blue a diamond, so the sides are not
/// told apart by colour alone. Selection adds a gold ring and a notch.
class BoardPiece extends StatelessWidget {
  const BoardPiece({
    super.key,
    required this.owner,
    required this.diameter,
    this.selected = false,
  });

  final Player owner;
  final double diameter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = PieceColors.maybeOf(context);
    final base = owner == Player.red
        ? (colors?.human ?? KiuthiTheme.redPiece)
        : (colors?.computer ?? KiuthiTheme.bluePiece);
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: PiecePainter(
          owner: owner,
          selected: selected,
          base: base,
          edge: PieceColors.edgeFor(base),
        ),
      ),
    );
  }
}

class PiecePainter extends CustomPainter {
  const PiecePainter({
    required this.owner,
    required this.selected,
    required this.base,
    required this.edge,
  });

  final Player owner;
  final bool selected;
  final Color base;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.36;

    canvas.drawCircle(
      center.translate(0, radius * 0.16),
      radius * 0.96,
      Paint()..color = const Color(0x40000000),
    );
    canvas.drawCircle(center, radius, Paint()..color = edge);
    canvas.drawCircle(
      center.translate(0, -radius * 0.05),
      radius * 0.84,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: [Color.lerp(base, Colors.white, 0.28)!, base, edge],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center.translate(-radius * 0.28, -radius * 0.34),
      radius * 0.16,
      Paint()..color = const Color(0x66FFFFFF),
    );

    final mark = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeJoin = StrokeJoin.round;
    if (owner == Player.red) {
      canvas.drawCircle(center, radius * 0.34, mark);
    } else {
      final diamond = Path()
        ..moveTo(center.dx, center.dy - radius * 0.42)
        ..lineTo(center.dx + radius * 0.36, center.dy)
        ..lineTo(center.dx, center.dy + radius * 0.42)
        ..lineTo(center.dx - radius * 0.36, center.dy)
        ..close();
      canvas.drawPath(diamond, mark);
    }

    if (!selected) return;
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..color = KiuthiTheme.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final notch = Path()
      ..moveTo(center.dx, center.dy - radius - 11)
      ..lineTo(center.dx - 6, center.dy - radius - 2)
      ..lineTo(center.dx + 6, center.dy - radius - 2)
      ..close();
    canvas.drawPath(notch, Paint()..color = KiuthiTheme.gold);
  }

  @override
  bool shouldRepaint(PiecePainter oldDelegate) {
    return oldDelegate.owner != owner ||
        oldDelegate.selected != selected ||
        oldDelegate.base != base ||
        oldDelegate.edge != edge;
  }
}
