import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/board_layout.dart';
import '../models/board_point.dart';
import '../models/board_state.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../theme/kiuthi_theme.dart';
import 'board_piece.dart';

class BoardGeometry {
  BoardGeometry(this.size);

  final Size size;

  double get pad => size.shortestSide * 0.09;
  double get span => size.shortestSide - pad * 2;
  double get step => span / 4;
  double get pieceBox => step * 0.92;

  Offset centerOf(BoardPoint point) =>
      Offset(pad + point.col * step, pad + point.row * step);
}

String kiuthiPointLabel(BoardState state, BoardPoint point) {
  final piece = state.pieceAt(point);
  final where = 'Row ${point.row + 1}, column ${point.col + 1}';
  if (piece == null) return '$where, empty';
  if (piece.owner == Player.red) return '$where, your piece';
  return '$where, computer piece';
}

class KiuthiBoard extends StatelessWidget {
  const KiuthiBoard({
    super.key,
    required this.state,
    required this.legalMoves,
    this.selectedPieceId,
    this.animating,
    this.animationT = 0,
    this.onPointTapped,
  });

  final BoardState state;
  final List<Move> legalMoves;
  final String? selectedPieceId;
  final Move? animating;
  final double animationT;
  final ValueChanged<BoardPoint>? onPointTapped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final geometry = BoardGeometry(Size(side, side));
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(side, side),
                  painter: _LinesPainter(
                    geometry: geometry,
                    legalMoves: legalMoves,
                  ),
                ),
                for (final piece in state.pieces)
                  if (!_hidden(piece))
                    _placedPiece(
                      geometry,
                      piece,
                      geometry.centerOf(piece.position),
                    ),
                if (animating != null) _animatedPiece(geometry),
                for (var index = 0; index < BoardState.pointCount; index++)
                  _target(geometry, BoardPoint.fromIndex(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hidden(Piece piece) {
    final move = animating;
    if (move == null) return false;
    if (piece.id == move.pieceId) return true;
    if (move.jumped != null &&
        piece.position == move.jumped &&
        animationT > 0.55) {
      return true;
    }
    return false;
  }

  Widget _animatedPiece(BoardGeometry geometry) {
    final move = animating!;
    final piece = state.pieceAt(move.from);
    if (piece == null) return const SizedBox.shrink();
    final center = Offset.lerp(
      geometry.centerOf(move.from),
      geometry.centerOf(move.to),
      Curves.easeInOut.transform(animationT.clamp(0, 1)),
    )!;
    return _placedPiece(geometry, piece, center, selected: true);
  }

  Widget _placedPiece(
    BoardGeometry geometry,
    Piece piece,
    Offset center, {
    bool selected = false,
  }) {
    final box = geometry.pieceBox;
    return Positioned(
      left: center.dx - box / 2,
      top: center.dy - box / 2,
      width: box,
      height: box,
      child: IgnorePointer(
        child: BoardPiece(
          owner: piece.owner,
          diameter: box,
          selected: selected || piece.id == selectedPieceId,
        ),
      ),
    );
  }

  Widget _target(BoardGeometry geometry, BoardPoint point) {
    final center = geometry.centerOf(point);
    final hit = math.max(geometry.step * 0.72, 36.0);
    final piece = state.pieceAt(point);
    return Positioned(
      left: center.dx - hit / 2,
      top: center.dy - hit / 2,
      width: hit,
      height: hit,
      child: Semantics(
        button: onPointTapped != null,
        selected: piece != null && piece.id == selectedPieceId,
        label: kiuthiPointLabel(state, point),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPointTapped == null ? null : () => onPointTapped!(point),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  const _LinesPainter({required this.geometry, required this.legalMoves});

  final BoardGeometry geometry;
  final List<Move> legalMoves;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final frame = RRect.fromRectAndRadius(
      bounds.deflate(6),
      const Radius.circular(26),
    );
    canvas.drawRRect(
      frame.shift(const Offset(0, 3)),
      Paint()..color = const Color(0x2E3E2723),
    );
    canvas.drawRRect(frame, Paint()..color = const Color(0xFF4A2C22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(11), const Radius.circular(22)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0B072), Color(0xFFC9956A), Color(0xFFA56B3C)],
        ).createShader(bounds),
    );

    final fieldRect = bounds.deflate(geometry.pad * 0.52);
    final field = RRect.fromRectAndRadius(fieldRect, const Radius.circular(16));
    canvas.drawRRect(field, Paint()..color = KiuthiTheme.field);
    canvas.save();
    canvas.clipRRect(field);
    final grain = Paint()
      ..color = const Color(0x18A56B3A)
      ..strokeWidth = 1;
    for (var y = fieldRect.top; y < fieldRect.bottom; y += 8) {
      canvas.drawLine(
        Offset(fieldRect.left, y),
        Offset(fieldRect.right, y + 12),
        grain,
      );
    }
    _camp(
      canvas,
      size,
      geometry.centerOf(const BoardPoint(0, 2)).dy + geometry.step * 0.4,
      geometry.step * 2.2,
      KiuthiTheme.bluePiece.withValues(alpha: 0.08),
    );
    _camp(
      canvas,
      size,
      geometry.centerOf(const BoardPoint(4, 2)).dy - geometry.step * 0.4,
      geometry.step * 2.2,
      KiuthiTheme.redPiece.withValues(alpha: 0.08),
    );
    canvas.restore();

    final line = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = math.max(1.6, geometry.step * 0.035)
      ..strokeCap = StrokeCap.round;
    for (final (from, to) in BoardLayout.edges) {
      canvas.drawLine(geometry.centerOf(from), geometry.centerOf(to), line);
    }

    for (var index = 0; index < BoardState.pointCount; index++) {
      final center = geometry.centerOf(BoardPoint.fromIndex(index));
      final radius = math.max(3.2, geometry.step * 0.055);
      canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF3E2723));
      canvas.drawCircle(
        center,
        radius * 0.45,
        Paint()..color = const Color(0xFFF8E7C8),
      );
    }

    for (final move in legalMoves) {
      final center = geometry.centerOf(move.to);
      final capture = move.kind == MoveKind.capture;
      final color = capture ? KiuthiTheme.capture : KiuthiTheme.moveGreen;
      canvas.drawCircle(
        center,
        geometry.step * 0.2,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      final ring = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6;
      canvas.drawCircle(center, geometry.step * 0.16, ring);
      if (!capture) {
        canvas.drawCircle(center, geometry.step * 0.045, Paint()..color = color);
        continue;
      }
      final arm = geometry.step * 0.07;
      canvas.drawLine(
        center.translate(-arm, -arm),
        center.translate(arm, arm),
        ring,
      );
      canvas.drawLine(
        center.translate(-arm, arm),
        center.translate(arm, -arm),
        ring,
      );
    }
  }

  void _camp(Canvas canvas, Size size, double centerY, double height, Color color) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, centerY),
        width: size.width,
        height: height,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_LinesPainter oldDelegate) => true;
}
