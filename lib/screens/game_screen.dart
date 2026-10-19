import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ai/ai_player.dart';
import '../engine/game_controller.dart';
import '../engine/move_validator.dart';
import '../models/board_point.dart';
import '../models/board_state.dart';
import '../models/game_result.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../storage/game_storage.dart';
import '../storage/settings_storage.dart';
import '../storage/statistics_storage.dart';
import '../theme/kiuthi_theme.dart';
import '../widgets/board_piece.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_status.dart';
import '../widgets/kiuthi_board.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.session,
    required this.settings,
    required this.statistics,
    required this.games,
  });

  final GameSession session;
  final SettingsStorage settings;
  final StatisticsStorage statistics;
  final GameStorage games;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameSession session;
  late final AnimationController _motion;
  String? _selectedId;
  String? _flash;
  Timer? _flashTimer;
  bool _thinking = false;
  bool _animating = false;
  bool _humanMotion = false;
  bool _overShown = false;
  int _turnEpoch = 0;
  Move? _animatingMove;
  AudioPlayer? _applause;

  @override
  void initState() {
    super.initState();
    session = widget.session;
    _selectedId = session.state.chainPieceId;
    _motion =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (mounted) setState(() {});
        });
    if (session.state.status != GameStatus.ongoing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishIfOver());
    } else if (session.state.activePlayer == Player.blue) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _computerTurn());
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _motion.dispose();
    _applause?.dispose();
    super.dispose();
  }

  bool get _busy => _thinking || _animating;

  bool get _dirty => session.state.positionHistory.length > 1;

  List<Move> get _shownMoves {
    final id = _selectedId;
    if (id == null) return const [];
    return session.legalMoves.where((move) => move.pieceId == id).toList();
  }

  void _show(String message) {
    _flashTimer?.cancel();
    setState(() => _flash = message);
    _flashTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  String get _statusMessage {
    if (_flash != null) return _flash!;
    if (session.state.status != GameStatus.ongoing) {
      return resultHeadline(session.state.status);
    }
    if (session.state.chainPieceId != null) {
      return 'You can capture again. Tap the orange circle.';
    }
    if (session.state.activePlayer == Player.blue) {
      return 'Computer to move.';
    }
    if (_selectedId != null) {
      return 'Gold marks your piece. Green is a move, orange is a capture.';
    }
    return 'Your turn. Tap one of your pieces.';
  }

  Future<void> _persist() {
    if (session.state.status != GameStatus.ongoing) {
      return widget.games.clear();
    }
    return widget.games.save(
      SavedGame(
        difficulty: session.difficulty,
        compulsoryCaptures: session.rules.capturesCompulsory,
        state: session.state,
      ),
    );
  }

  /// Returns false when undo cancelled this motion.
  Future<bool> _animate(Move move, {required bool human}) async {
    final epoch = _turnEpoch;
    setState(() {
      _animating = true;
      _humanMotion = human;
      _animatingMove = move;
    });
    await _motion.forward(from: 0);
    if (!mounted || epoch != _turnEpoch) return false;
    if (widget.settings.sound) {
      SystemSound.play(SystemSoundType.click);
    }
    return true;
  }

  Future<void> _playHuman(Move move) async {
    final epoch = _turnEpoch;
    final finished = await _animate(move, human: true);
    if (!mounted || !finished || epoch != _turnEpoch) return;
    final played = session.applyHumanMove(move);
    setState(() {
      _animating = false;
      _humanMotion = false;
      _animatingMove = null;
      _selectedId = session.state.chainPieceId;
    });
    if (!played) {
      _show('That move is not legal.');
      return;
    }
    if (session.state.chainPieceId != null) {
      await _persist();
      return;
    }
    await _persist();
    if (session.state.status != GameStatus.ongoing) {
      await _finishIfOver();
      return;
    }
    await _computerTurn();
  }

  Future<void> _computerTurn() async {
    if (!mounted || session.state.status != GameStatus.ongoing) return;
    if (session.state.activePlayer != Player.blue) return;
    final token = session.guard.start();
    final epoch = _turnEpoch;
    final key = session.state.positionKey;
    setState(() => _thinking = true);
    final encoded = await compute(
      kiuthiChooseMove,
      encodeAiPayload(
        state: session.state,
        difficulty: session.difficulty,
        rules: session.rules,
        seed: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted || !session.guard.accepts(token) || epoch != _turnEpoch) {
      return;
    }
    if (session.state.positionKey != key) return;
    setState(() => _thinking = false);

    if (encoded.isEmpty) {
      session.adjudicateIfNoMove();
      if (session.state.status == GameStatus.ongoing) {
        _show('The computer could not choose a legal move.');
      }
      await _finishIfOver();
      return;
    }

    final moves = MoveValidator.adaptEncoded(
      session.state,
      encoded,
      session.rules,
    );
    if (moves == null) {
      _show('The computer returned a move that the rules rejected.');
      return;
    }

    for (final move in moves) {
      if (!mounted || !session.guard.accepts(token) || epoch != _turnEpoch) {
        return;
      }
      final finished = await _animate(move, human: false);
      if (!mounted ||
          !finished ||
          !session.guard.accepts(token) ||
          epoch != _turnEpoch) {
        return;
      }
      final applied = session.applyComputerStep(move);
      setState(() {
        _animating = false;
        _humanMotion = false;
        _animatingMove = null;
      });
      if (!applied) {
        _show('The computer returned a move that the rules rejected.');
        return;
      }
    }
    await _persist();
    await _finishIfOver();
  }

  Future<void> _finishIfOver() async {
    if (!mounted || _overShown) return;
    if (session.state.status == GameStatus.ongoing) return;
    _overShown = true;
    final board = session.state;
    if (board.status == GameStatus.redWins) unawaited(_cheer());
    if (!mounted) return;
    final action = await Navigator.of(context).push<OverAction>(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          state: session.state,
          difficulty: session.difficulty,
          canUndo: session.canUndo,
        ),
      ),
    );
    if (!mounted) return;
    if (action == OverAction.undo) {
      final undone = session.undo();
      _turnEpoch++;
      _motion.stop();
      unawaited(_applause?.stop());
      setState(() {
        _overShown = false;
        _thinking = false;
        _animating = false;
        _humanMotion = false;
        _animatingMove = null;
        _selectedId = session.state.chainPieceId;
        _flash = null;
      });
      if (undone) await _persist();
      return;
    }
    widget.statistics.record(
      difficulty: session.difficulty,
      status: board.status,
      reason: board.endReason,
      humanCaptured: board.redCaptured,
      computerCaptured: board.blueCaptured,
      humanLeft: board.count(Player.red),
      computerLeft: board.count(Player.blue),
    );
    await widget.statistics.persist();
    await widget.games.clear();
    if (!mounted) return;
    switch (action) {
      case OverAction.again:
        setState(() {
          session.restart();
          _selectedId = null;
          _flash = null;
          _overShown = false;
        });
        await _persist();
        break;
      case OverAction.changeDifficulty:
      case OverAction.home:
        Navigator.of(context).pop();
        break;
      case OverAction.undo:
      case null:
        break;
    }
  }

  void _onPoint(BoardPoint point) {
    if (_busy || session.state.status != GameStatus.ongoing) return;
    if (session.state.activePlayer != Player.red) return;

    final piece = session.state.pieceAt(point);
    if (_selectedId != null) {
      final matches = _shownMoves.where((move) => move.to == point);
      if (matches.isNotEmpty) {
        _playHuman(matches.first);
        return;
      }
    }

    if (piece != null && piece.owner == Player.red) {
      if (session.state.chainPieceId != null &&
          piece.id != session.state.chainPieceId) {
        _show('Finish the capture with the highlighted piece.');
        return;
      }
      final moves = session.legalMoves
          .where((move) => move.pieceId == piece.id)
          .toList();
      setState(() => _selectedId = piece.id);
      if (moves.isEmpty) _show('That piece has no legal move.');
      return;
    }

    if (piece != null && piece.owner == Player.blue) {
      _show("That is the computer's piece.");
      return;
    }
    if (_selectedId == null) {
      _show('Select one of your pieces first.');
      return;
    }
    _show('That move is not legal.');
  }

  Future<void> _cheer() async {
    if (!widget.settings.sound) return;
    final player = _applause ??= AudioPlayer();
    await player.stop();
    await player.play(AssetSource('applause.wav'));
  }

  Future<void> _undo() async {
    if (_humanMotion) return;
    final undone = session.undo();
    if (!undone) {
      _show('Nothing to undo yet.');
      return;
    }
    _turnEpoch++;
    _motion.stop();
    unawaited(_applause?.stop());
    setState(() {
      _thinking = false;
      _animating = false;
      _humanMotion = false;
      _animatingMove = null;
      _overShown = false;
      _selectedId = session.state.chainPieceId;
      _flash = null;
    });
    await _persist();
  }

  Future<void> _restart() async {
    if (_dirty) {
      final discard = await confirmDiscard(context, 'Restart this game?');
      if (!discard || !mounted) return;
    }
    setState(() {
      session.restart();
      _selectedId = null;
      _thinking = false;
      _flash = null;
      _overShown = false;
    });
    await widget.games.clear();
  }

  Future<void> _home() async {
    if (_dirty) {
      final discard = await confirmDiscard(context, 'Leave this game?');
      if (!discard || !mounted) return;
      session.guard.invalidate();
      await widget.games.clear();
    } else {
      await _persist();
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pause() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paused'),
          content: Text(
            '${session.difficulty.label} · the board stays as it is.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restart();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _home();
              },
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget _banners(BoardState state, bool redTurn, {required bool beside}) {
    final you = PlayerBanner(
      title: 'You · Red',
      detail:
          '${state.count(Player.red)} pieces · captured ${state.redCaptured}',
      mark: const BoardPiece(owner: Player.red, diameter: 32),
      active: redTurn,
      taken: state.redCaptured,
      takenOwner: Player.blue,
    );
    final computer = PlayerBanner(
      title: 'Computer · Blue',
      detail:
          '${state.count(Player.blue)} pieces · captured ${state.blueCaptured}',
      mark: const BoardPiece(owner: Player.blue, diameter: 32),
      active: !redTurn && state.status == GameStatus.ongoing,
      taken: state.blueCaptured,
      takenOwner: Player.red,
    );
    if (beside) {
      return Column(children: [you, const SizedBox(height: 8), computer]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: you),
          const SizedBox(width: 8),
          Expanded(child: computer),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final state = session.state;
    final redTurn =
        state.activePlayer == Player.red && state.status == GameStatus.ongoing;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _home();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kiuthi · ${session.difficulty.label}'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: KiuthiTheme.sandDeep),
          ),
          leading: IconButton(
            tooltip: 'Home',
            onPressed: _home,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: 'Pause',
              onPressed: _pause,
              icon: const Icon(Icons.pause_circle_outline),
            ),
          ],
        ),
        body: KiuthiPage(
          maxWidth: 840,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final landscape = constraints.maxWidth > constraints.maxHeight;
                final board = KiuthiBoard(
                  state: state,
                  legalMoves: _busy ? const [] : _shownMoves,
                  selectedPieceId: _selectedId,
                  animating: _animatingMove,
                  animationT: _motion.value,
                  onPointTapped: _onPoint,
                );
                final status = StatusLine(message: _statusMessage);
                final controls = GameControls(
                  undoEnabled: session.canUndo && !_humanMotion,
                  onUndo: _undo,
                  onRestart: _restart,
                  onHome: _home,
                );
                if (landscape) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: board),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: constraints.maxWidth * 0.34,
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: _banners(state, redTurn, beside: true),
                              ),
                            ),
                            const SizedBox(height: 8),
                            status,
                            const SizedBox(height: 8),
                            controls,
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _banners(state, redTurn, beside: false),
                    const SizedBox(height: 8),
                    Expanded(child: board),
                    const SizedBox(height: 8),
                    status,
                    const SizedBox(height: 10),
                    controls,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
