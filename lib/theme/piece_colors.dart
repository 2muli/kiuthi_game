import 'package:flutter/material.dart';

import 'kiuthi_theme.dart';

/// Piece colours chosen in Settings. Wrapped around the navigator so a
/// game route sees the same colours as the tabs.
class PieceColors extends InheritedWidget {
  const PieceColors({
    super.key,
    required this.human,
    required this.computer,
    required super.child,
  });

  final Color human;
  final Color computer;

  static PieceColors? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PieceColors>();
  }

  Color forOwnerIsHuman(bool humanOwner) => humanOwner ? human : computer;

  static bool same(Color a, Color b) => a.toARGB32() == b.toARGB32();

  /// A computer colour that is not [taken].
  static Color computerDistinctFrom(Color taken) {
    for (final color in computerChoices) {
      if (!same(color, taken)) return color;
    }
    for (final color in humanChoices) {
      if (!same(color, taken)) return color;
    }
    return KiuthiTheme.bluePiece;
  }

  static Color edgeFor(Color color) =>
      Color.lerp(color, const Color(0xFF1A1A1A), 0.38) ?? color;

  /// Every swatch. A colour already chosen for one side is left out of the other.
  static const choices = <Color>[
    KiuthiTheme.redPiece,
    Color(0xFFAD1457),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    KiuthiTheme.bluePiece,
    Color(0xFF00838F),
    Color(0xFF283593),
    Color(0xFF37474F),
    Color(0xFF4E342E),
  ];

  static List<Color> except(Color taken) {
    return [
      for (final color in choices)
        if (!same(color, taken)) color,
    ];
  }

  static const humanChoices = <Color>[
    KiuthiTheme.redPiece,
    Color(0xFFAD1457),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
  ];

  static const computerChoices = <Color>[
    KiuthiTheme.bluePiece,
    Color(0xFF00838F),
    Color(0xFF283593),
    Color(0xFF37474F),
    Color(0xFF4E342E),
  ];

  @override
  bool updateShouldNotify(PieceColors oldWidget) {
    return oldWidget.human != human || oldWidget.computer != computer;
  }
}
