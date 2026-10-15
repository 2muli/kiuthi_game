import 'board_point.dart';
import 'game_result.dart';
import 'piece.dart';

/// Full legal position, including whose turn it is and any capture chain.
class BoardState {
  BoardState({
    required List<Piece?> cells,
    required this.activePlayer,
    this.status = GameStatus.ongoing,
    this.endReason = EndReason.none,
    this.redCaptured = 0,
    this.blueCaptured = 0,
    this.chainPieceId,
    this.chainDeltaRow,
    this.chainDeltaCol,
    List<String>? positionHistory,
  }) : cells = List<Piece?>.unmodifiable(cells),
       positionHistory = List<String>.unmodifiable(
         positionHistory ?? const <String>[],
       );

  /// Length 25. Index is `row * 5 + column`.
  final List<Piece?> cells;
  final Player activePlayer;
  final GameStatus status;
  final EndReason endReason;
  final int redCaptured;
  final int blueCaptured;

  /// When set, this piece must keep jumping. The turn has not ended.
  final String? chainPieceId;
  final int? chainDeltaRow;
  final int? chainDeltaCol;
  final List<String> positionHistory;

  static const int pointCount = 25;

  factory BoardState.initial() {
    final cells = List<Piece?>.filled(pointCount, null);
    var blueIndex = 0;
    var redIndex = 0;
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        final Player? owner;
        if (row <= 1) {
          owner = Player.blue;
        } else if (row >= 3) {
          owner = Player.red;
        } else {
          owner = null;
        }
        if (owner == null) continue;
        final id = owner == Player.blue ? 'B$blueIndex' : 'R$redIndex';
        if (owner == Player.blue) {
          blueIndex += 1;
        } else {
          redIndex += 1;
        }
        final point = BoardPoint(row, col);
        cells[point.index] = Piece(
          id: id,
          owner: owner,
          position: point,
          hasCrossed: false,
        );
      }
    }
    final state = BoardState(cells: cells, activePlayer: Player.red);
    return state.copyWith(positionHistory: [state.positionKey]);
  }

  Piece? pieceAt(BoardPoint point) => cells[point.index];

  Piece? pieceById(String id) {
    for (final piece in cells) {
      if (piece != null && piece.id == id) return piece;
    }
    return null;
  }

  Iterable<Piece> get pieces => cells.whereType<Piece>();

  int count(Player player) =>
      pieces.where((piece) => piece.owner == player).length;

  int crossedCount(Player player) =>
      pieces.where((piece) => piece.owner == player && piece.hasCrossed).length;

  /// 0 empty, 1 red, 2 red crossed, 3 blue, 4 blue crossed.
  List<int> get cellCodes => [
    for (final piece in cells)
      if (piece == null)
        0
      else if (piece.owner == Player.red)
        piece.hasCrossed ? 2 : 1
      else
        piece.hasCrossed ? 4 : 3,
  ];

  String get positionKey {
    final buffer = StringBuffer(activePlayer.name)
      ..write('|')
      ..write(chainPieceId ?? '-');
    for (final piece in cells) {
      if (piece == null) {
        buffer.write('.');
      } else {
        buffer
          ..write(piece.owner == Player.red ? 'R' : 'B')
          ..write(piece.hasCrossed ? '*' : '');
      }
    }
    return buffer.toString();
  }

  BoardState copyWith({
    List<Piece?>? cells,
    Player? activePlayer,
    GameStatus? status,
    EndReason? endReason,
    int? redCaptured,
    int? blueCaptured,
    String? chainPieceId,
    bool clearChain = false,
    int? chainDeltaRow,
    int? chainDeltaCol,
    bool clearDelta = false,
    List<String>? positionHistory,
  }) {
    return BoardState(
      cells: cells ?? this.cells,
      activePlayer: activePlayer ?? this.activePlayer,
      status: status ?? this.status,
      endReason: endReason ?? this.endReason,
      redCaptured: redCaptured ?? this.redCaptured,
      blueCaptured: blueCaptured ?? this.blueCaptured,
      chainPieceId: clearChain ? null : (chainPieceId ?? this.chainPieceId),
      chainDeltaRow: clearDelta ? null : (chainDeltaRow ?? this.chainDeltaRow),
      chainDeltaCol: clearDelta ? null : (chainDeltaCol ?? this.chainDeltaCol),
      positionHistory: positionHistory ?? this.positionHistory,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'active': activePlayer.name,
      'status': status.name,
      'reason': endReason.name,
      'redCaptured': redCaptured,
      'blueCaptured': blueCaptured,
      'chain': chainPieceId,
      'chainDeltaRow': chainDeltaRow,
      'chainDeltaCol': chainDeltaCol,
      'history': positionHistory,
      'cells': [
        for (final piece in cells)
          if (piece == null)
            null
          else
            {
              'id': piece.id,
              'owner': piece.owner.name,
              'crossed': piece.hasCrossed,
            },
      ],
    };
  }

  /// Returns null when the payload cannot represent a legal position.
  static BoardState? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final activeRaw = raw['active'];
    final cellsRaw = raw['cells'];
    if (activeRaw is! String || cellsRaw is! List || cellsRaw.length != 25) {
      return null;
    }
    late final Player active;
    try {
      active = Player.parse(activeRaw);
    } on FormatException {
      return null;
    }

    final cells = List<Piece?>.filled(25, null);
    final seen = <String>{};
    for (var index = 0; index < 25; index++) {
      final entry = cellsRaw[index];
      if (entry == null) continue;
      if (entry is! Map) return null;
      final id = entry['id'];
      final ownerRaw = entry['owner'];
      final crossed = entry['crossed'];
      if (id is! String || id.isEmpty || ownerRaw is! String) return null;
      if (crossed is! bool) return null;
      if (!seen.add(id)) return null;
      late final Player owner;
      try {
        owner = Player.parse(ownerRaw);
      } on FormatException {
        return null;
      }
      final point = BoardPoint.fromIndex(index);
      cells[index] = Piece(
        id: id,
        owner: owner,
        position: point,
        hasCrossed: crossed,
      );
    }

    final redCaptured = raw['redCaptured'];
    final blueCaptured = raw['blueCaptured'];
    if (redCaptured is! int || blueCaptured is! int) return null;
    if (redCaptured < 0 || blueCaptured < 0) return null;

    final redLeft = cells
        .whereType<Piece>()
        .where((p) => p.owner == Player.red)
        .length;
    final blueLeft = cells
        .whereType<Piece>()
        .where((p) => p.owner == Player.blue)
        .length;
    if (redLeft + blueCaptured != 10 || blueLeft + redCaptured != 10) {
      return null;
    }

    final chain = raw['chain'];
    if (chain != null && chain is! String) return null;
    if (chain is String) {
      final chained = cells.whereType<Piece>().where((p) => p.id == chain);
      if (chained.length != 1 || chained.first.owner != active) return null;
    }

    final status = _status(raw['status']);
    final reason = _reason(raw['reason']);
    if (status == null || reason == null) return null;

    final historyRaw = raw['history'];
    final history = <String>[];
    if (historyRaw is List) {
      for (final item in historyRaw) {
        if (item is! String) return null;
        history.add(item);
      }
    }

    final deltaRow = raw['chainDeltaRow'];
    final deltaCol = raw['chainDeltaCol'];
    if (deltaRow != null && deltaRow is! int) return null;
    if (deltaCol != null && deltaCol is! int) return null;

    final state = BoardState(
      cells: cells,
      activePlayer: active,
      status: status,
      endReason: reason,
      redCaptured: redCaptured,
      blueCaptured: blueCaptured,
      chainPieceId: chain as String?,
      chainDeltaRow: deltaRow as int?,
      chainDeltaCol: deltaCol as int?,
      positionHistory: history.isEmpty ? null : history,
    );
    if (state.positionHistory.isEmpty) {
      return state.copyWith(positionHistory: [state.positionKey]);
    }
    return state;
  }

  static GameStatus? _status(Object? value) {
    if (value is! String) return null;
    for (final status in GameStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  static EndReason? _reason(Object? value) {
    if (value is! String) return null;
    for (final reason in EndReason.values) {
      if (reason.name == value) return reason;
    }
    return null;
  }
}

/// Builds custom positions for examples and tests.
class PositionSetup {
  final List<Piece?> _cells = List<Piece?>.filled(BoardState.pointCount, null);
  int _red = 0;
  int _blue = 0;

  void put(Player owner, int row, int col, {bool crossed = false, String? id}) {
    final point = BoardPoint(row, col);
    if (!point.isOnBoard) {
      throw ArgumentError('Point off the board: $point');
    }
    if (_cells[point.index] != null) {
      throw ArgumentError('Point already occupied: $point');
    }
    final pieceId = id ?? (owner == Player.red ? 'R${_red++}' : 'B${_blue++}');
    _cells[point.index] = Piece(
      id: pieceId,
      owner: owner,
      position: point,
      hasCrossed: crossed,
    );
  }

  BoardState build({
    Player active = Player.red,
    String? chainPieceId,
    int? chainDeltaRow,
    int? chainDeltaCol,
  }) {
    var redLeft = 0;
    var blueLeft = 0;
    for (final piece in _cells) {
      if (piece == null) continue;
      if (piece.owner == Player.red) {
        redLeft += 1;
      } else {
        blueLeft += 1;
      }
    }
    final state = BoardState(
      cells: _cells,
      activePlayer: active,
      redCaptured: 10 - blueLeft,
      blueCaptured: 10 - redLeft,
      chainPieceId: chainPieceId,
      chainDeltaRow: chainDeltaRow,
      chainDeltaCol: chainDeltaCol,
    );
    return state.copyWith(positionHistory: [state.positionKey]);
  }
}
