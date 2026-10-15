import '../models/board_state.dart';
import '../models/piece.dart';

class _ExactEntry {
  const _ExactEntry(this.lo, this.hi, this.depth, this.score);

  final int lo;
  final int hi;
  final int depth;
  final double score;
}

/// Exact-score cache. Entries are stored only when a node was fully searched,
/// so a beta cutoff is never reused as an exact value.
class TranspositionTable {
  final Map<int, _ExactEntry> _entries = {};
  static const int _limit = 20000;

  (int, int) fingerprint(BoardState state) {
    var lo = 0;
    var hi = state.activePlayer == Player.blue ? 1 : 0;
    final codes = state.cellCodes;
    for (var i = 0; i < codes.length; i++) {
      if (i < 10) {
        lo |= codes[i] << (i * 3);
      } else {
        hi |= codes[i] << ((i - 10) * 3 + 1);
      }
    }
    return (lo, hi);
  }

  int hash(BoardState state) {
    final (lo, hi) = fingerprint(state);
    return lo ^ (hi << 1);
  }

  double? probe(BoardState state, int depth) {
    final key = hash(state);
    final entry = _entries[key];
    if (entry == null || entry.depth < depth) return null;
    final (lo, hi) = fingerprint(state);
    if (entry.lo != lo || entry.hi != hi) return null;
    return entry.score;
  }

  void store(BoardState state, int depth, double score) {
    if (_entries.length >= _limit) _entries.clear();
    final (lo, hi) = fingerprint(state);
    _entries[hash(state)] = _ExactEntry(lo, hi, depth, score);
  }
}
