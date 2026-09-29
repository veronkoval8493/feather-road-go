import 'dart:math' as math;

import 'levels.dart';

/// Directions: 0 = up, 1 = right, 2 = down, 3 = left.
const List<int> kDr = <int>[-1, 0, 1, 0];
const List<int> kDc = <int>[0, 1, 0, -1];

enum TileKind { source, target, straight, elbow }

class TileModel {
  final TileKind kind;
  final int pairIndex;
  final int solvedRot;

  /// Only meaningful for [TileKind.source] / [TileKind.target]: the single
  /// direction the endpoint opens towards. Endpoints never rotate.
  final int fixedDir;

  int rot;

  TileModel({
    required this.kind,
    required this.pairIndex,
    required this.solvedRot,
    required this.fixedDir,
    required this.rot,
  });

  bool get isEndpoint => kind == TileKind.source || kind == TileKind.target;

  TileModel copySolved() => TileModel(
        kind: kind,
        pairIndex: pairIndex,
        solvedRot: solvedRot,
        fixedDir: fixedDir,
        rot: solvedRot,
      );
}

/// Port bitmask of a tile in a given rotation (bit d set = open towards d).
int portsMask(TileKind kind, int rot, int fixedDir) {
  switch (kind) {
    case TileKind.straight:
      return rot % 2 == 0 ? (1 << 0) | (1 << 2) : (1 << 1) | (1 << 3);
    case TileKind.elbow:
      return (1 << (rot % 4)) | (1 << ((rot + 1) % 4));
    case TileKind.source:
    case TileKind.target:
      return 1 << fixedDir;
  }
}

/// Minimum number of 90-degree taps needed to reach orientation [to] from
/// [from]. Straight tiles repeat every two turns, so their cost never exceeds
/// one.
int rotCost(TileKind kind, int from, int to, int fixedDir) {
  final int want = portsMask(kind, to, fixedDir);
  for (int d = 0; d < 4; d++) {
    if (portsMask(kind, (from + d) % 4, fixedDir) == want) return d;
  }
  return 0;
}

class BoardState {
  final SchemeModel scheme;
  final int rows;
  final int cols;
  final int pairs;
  final List<TileModel> grid;
  final Map<int, int> sources;
  final Map<int, int> targets;
  final int minMoves;

  int movesLeft;
  int checksLeft;

  BoardState({
    required this.scheme,
    required this.rows,
    required this.cols,
    required this.pairs,
    required this.grid,
    required this.sources,
    required this.targets,
    required this.minMoves,
    required this.movesLeft,
    required this.checksLeft,
  });

  TileModel tileAt(int r, int c) => grid[r * cols + c];

  int get movesLimit => minMoves + scheme.slack;

  BoardState solvedCopy() => BoardState(
        scheme: scheme,
        rows: rows,
        cols: cols,
        pairs: pairs,
        grid: grid.map((TileModel t) => t.copySolved()).toList(),
        sources: sources,
        targets: targets,
        minMoves: minMoves,
        movesLeft: movesLeft,
        checksLeft: checksLeft,
      );
}

/// Serpentine band carving. Every band covers a contiguous strip of the grid
/// and visits each of its cells exactly once, so the resulting routes can never
/// cross and every scheme has a guaranteed solution.
List<List<int>> carvePaths(SchemeModel s) {
  final List<List<int>> paths = <List<int>>[];
  int startLine = 0;

  for (int b = 0; b < s.bands.length; b++) {
    final int width = s.bands[b];
    final List<int> cells = <int>[];
    for (int i = 0; i < width; i++) {
      final bool forward = (i % 2 == 0) != s.flip;
      if (s.vertical) {
        final int c = startLine + i;
        if (forward) {
          for (int r = 0; r < s.rows; r++) {
            cells.add(r * s.cols + c);
          }
        } else {
          for (int r = s.rows - 1; r >= 0; r--) {
            cells.add(r * s.cols + c);
          }
        }
      } else {
        final int r = startLine + i;
        if (forward) {
          for (int c = 0; c < s.cols; c++) {
            cells.add(r * s.cols + c);
          }
        } else {
          for (int c = s.cols - 1; c >= 0; c--) {
            cells.add(r * s.cols + c);
          }
        }
      }
    }
    paths.add(cells);
    startLine += width;
  }
  return paths;
}

int _dirBetween(int fromIdx, int toIdx, int cols) {
  final int fr = fromIdx ~/ cols;
  final int fc = fromIdx % cols;
  final int tr = toIdx ~/ cols;
  final int tc = toIdx % cols;
  for (int d = 0; d < 4; d++) {
    if (fr + kDr[d] == tr && fc + kDc[d] == tc) return d;
  }
  return 0;
}

int _solvedRotFor(TileKind kind, int mask) {
  for (int rot = 0; rot < 4; rot++) {
    if (portsMask(kind, rot, 0) == mask) return rot;
  }
  return 0;
}

/// Builds a scrambled but always-solvable board for [scheme].
BoardState buildBoard(SchemeModel scheme) {
  final List<List<int>> paths = carvePaths(scheme);
  final int cells = scheme.rows * scheme.cols;

  final List<TileModel?> slots = List<TileModel?>.filled(cells, null);
  final Map<int, int> sources = <int, int>{};
  final Map<int, int> targets = <int, int>{};

  for (int p = 0; p < paths.length; p++) {
    final List<int> path = paths[p];
    for (int i = 0; i < path.length; i++) {
      final int idx = path[i];
      if (i == 0) {
        final int dir = _dirBetween(idx, path[i + 1], scheme.cols);
        slots[idx] = TileModel(
          kind: TileKind.source,
          pairIndex: p,
          solvedRot: 0,
          fixedDir: dir,
          rot: 0,
        );
        sources[p] = idx;
      } else if (i == path.length - 1) {
        final int dir = _dirBetween(idx, path[i - 1], scheme.cols);
        slots[idx] = TileModel(
          kind: TileKind.target,
          pairIndex: p,
          solvedRot: 0,
          fixedDir: dir,
          rot: 0,
        );
        targets[p] = idx;
      } else {
        final int dIn = _dirBetween(idx, path[i - 1], scheme.cols);
        final int dOut = _dirBetween(idx, path[i + 1], scheme.cols);
        final int mask = (1 << dIn) | (1 << dOut);
        final TileKind kind =
            (dIn + 2) % 4 == dOut ? TileKind.straight : TileKind.elbow;
        final int solved = _solvedRotFor(kind, mask);
        slots[idx] = TileModel(
          kind: kind,
          pairIndex: p,
          solvedRot: solved,
          fixedDir: 0,
          rot: solved,
        );
      }
    }
  }

  final List<TileModel> grid =
      slots.map((TileModel? t) => t!).toList(growable: false);

  // Scramble: deterministic, and never so gentle that the board starts solved.
  final math.Random rnd = math.Random(scheme.seed);
  int minMoves = 0;
  for (final TileModel t in grid) {
    if (t.isEndpoint) continue;
    if (rnd.nextDouble() < 0.72) {
      final int delta = t.kind == TileKind.straight
          ? (rnd.nextBool() ? 1 : 3)
          : 1 + rnd.nextInt(3);
      t.rot = (t.solvedRot + delta) % 4;
    }
    minMoves += rotCost(t.kind, t.rot, t.solvedRot, t.fixedDir);
  }
  if (minMoves == 0) {
    for (final TileModel t in grid) {
      if (t.isEndpoint) continue;
      t.rot = (t.solvedRot + 1) % 4;
      minMoves = rotCost(t.kind, t.rot, t.solvedRot, t.fixedDir);
      break;
    }
  }

  return BoardState(
    scheme: scheme,
    rows: scheme.rows,
    cols: scheme.cols,
    pairs: paths.length,
    grid: grid,
    sources: sources,
    targets: targets,
    minMoves: minMoves,
    movesLeft: minMoves + scheme.slack,
    checksLeft: 3,
  );
}

/// Follows the chain leaving the grain sack of [pair]. Returns the cell indices
/// of a completed road, or null while the road is still broken.
List<int>? traceRoute(BoardState b, int pair) {
  final int? srcIdx = b.sources[pair];
  if (srcIdx == null) return null;

  int dir = b.grid[srcIdx].fixedDir;
  int r = srcIdx ~/ b.cols;
  int c = srcIdx % b.cols;
  final List<int> path = <int>[srcIdx];

  for (int step = 0; step <= b.rows * b.cols; step++) {
    r += kDr[dir];
    c += kDc[dir];
    if (r < 0 || c < 0 || r >= b.rows || c >= b.cols) return null;

    final int idx = r * b.cols + c;
    final TileModel t = b.grid[idx];
    final int back = (dir + 2) % 4;
    final int mask = portsMask(t.kind, t.rot, t.fixedDir);
    if ((mask & (1 << back)) == 0) return null;

    path.add(idx);
    if (t.kind == TileKind.target) {
      return t.pairIndex == pair ? path : null;
    }
    if (t.kind == TileKind.source) return null;

    final int outMask = mask & ~(1 << back);
    int outDir = -1;
    for (int d = 0; d < 4; d++) {
      if ((outMask & (1 << d)) != 0) {
        if (outDir != -1) return null;
        outDir = d;
      }
    }
    if (outDir == -1) return null;
    dir = outDir;
  }
  return null;
}

/// All completed roads, keyed by pair index.
Map<int, List<int>> completedRoutes(BoardState b) {
  final Map<int, List<int>> done = <int, List<int>>{};
  for (int p = 0; p < b.pairs; p++) {
    final List<int>? path = traceRoute(b, p);
    if (path != null) done[p] = path;
  }
  return done;
}

int starsFor(BoardState b, int movesLeft) {
  final int slack = b.scheme.slack;
  if (movesLeft >= slack) return 3;
  if (movesLeft * 2 >= slack) return 2;
  return 1;
}

/// A finished round, handed to the game-over screen.
class GameResult {
  final bool win;
  final int stars;
  final int schemeIndex;
  final int pairsDone;
  final int pairsTotal;
  final int movesLeft;
  final int rows;
  final int cols;

  /// Cell chains of the fully solved board, used for the mini preview.
  final List<List<int>> solvedRoutes;

  const GameResult({
    required this.win,
    required this.stars,
    required this.schemeIndex,
    required this.pairsDone,
    required this.pairsTotal,
    required this.movesLeft,
    required this.rows,
    required this.cols,
    required this.solvedRoutes,
  });

  int get grainReward => win ? (stars == 3 ? 50 : (stars == 2 ? 35 : 20)) : 0;
}
