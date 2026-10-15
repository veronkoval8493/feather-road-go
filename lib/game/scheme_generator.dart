import 'dart:math' as math;

import 'board_state.dart';
import 'schemes.dart';

/// Constructive board generator: the three solution trails are carved first and
/// own their cells, so a generated board is non-crossing and solvable by
/// construction rather than by hope.
BoardState generateBoard(SchemeDef scheme) {
  for (int attempt = 0; attempt < 80; attempt++) {
    final BoardState? board =
        _tryBuild(scheme, math.Random(scheme.seed + attempt * 7919));
    if (board != null) {
      return board;
    }
  }
  return _straightFallback(scheme);
}

/// A tiny hand-built 3x3 board used by the rules panel.
BoardState demoBoard({int route = 0, int postOrientation = kDirDown}) {
  const int cols = 3;
  const int rows = 3;
  final List<CellKind> kinds =
      List<CellKind>.filled(cols * rows, CellKind.empty);
  final List<int> routeOf = List<int>.filled(cols * rows, -1);
  final List<int> orientation = List<int>.filled(cols * rows, kDirRight);
  final List<int> solution = List<int>.filled(cols * rows, kDirRight);

  const int sack = 3;
  const int post = 4;
  const int feeder = 5;
  kinds[sack] = CellKind.sack;
  kinds[post] = CellKind.post;
  kinds[feeder] = CellKind.feeder;
  routeOf[sack] = route;
  routeOf[feeder] = route;
  orientation[post] = postOrientation;
  solution[post] = kDirRight;

  return BoardState(
    cols: cols,
    rows: rows,
    kinds: kinds,
    routeOf: routeOf,
    orientation: orientation,
    solutionOrientation: solution,
    sacks: <int>[sack],
    feeders: <int>[feeder],
    parMoves: 1,
  );
}

BoardState? _tryBuild(SchemeDef scheme, math.Random rng) {
  final int cols = scheme.cols;
  final int rows = scheme.rows;
  final int count = cols * rows;

  final List<int> sackRows =
      (List<int>.generate(rows, (int i) => i)..shuffle(rng)).take(3).toList()
        ..sort();
  // Sack rows and feeder rows are drawn independently but both kept in
  // ascending order, so route N always sits above route N+1. That ordering is
  // what makes three non-crossing solution paths possible at all; a permuted
  // pairing would force a crossing no matter how the paths are carved.
  // Different rows on the two sides are preferred, so trails have to turn.
  List<int> feederRows = sackRows;
  for (int draw = 0; draw < 5; draw++) {
    final List<int> candidate =
        (List<int>.generate(rows, (int i) => i)..shuffle(rng)).take(3).toList()
          ..sort();
    feederRows = candidate;
    if (!_sameRows(candidate, sackRows)) {
      break;
    }
  }

  final List<CellKind> kinds = List<CellKind>.filled(count, CellKind.empty);
  final List<int> routeOf = List<int>.filled(count, -1);
  final List<int> orientation = List<int>.filled(count, kDirRight);
  final List<int> solution = List<int>.filled(count, kDirRight);
  final List<bool> owned = List<bool>.filled(count, false);

  final List<int> sacks = <int>[];
  final List<int> feeders = <int>[];
  for (int route = 0; route < 3; route++) {
    final int sack = sackRows[route] * cols;
    final int feeder = feederRows[route] * cols + cols - 1;
    sacks.add(sack);
    feeders.add(feeder);
    kinds[sack] = CellKind.sack;
    kinds[feeder] = CellKind.feeder;
    routeOf[sack] = route;
    routeOf[feeder] = route;
    orientation[sack] = kDirRight;
    solution[sack] = kDirRight;
    owned[sack] = true;
    owned[feeder] = true;
  }

  final List<int> postCells = <int>[];
  for (int route = 0; route < 3; route++) {
    final int start = sackRows[route] * cols + 1;
    final int target = feederRows[route] * cols + cols - 2;
    if (owned[start] || owned[target]) {
      return null;
    }
    final List<int>? path = _carvePath(cols, rows, owned, start, target, rng);
    if (path == null) {
      return null;
    }
    for (int i = 0; i < path.length; i++) {
      final int cell = path[i];
      final int next = i + 1 < path.length ? path[i + 1] : feeders[route];
      owned[cell] = true;
      kinds[cell] = CellKind.post;
      solution[cell] = _directionBetween(cols, cell, next);
      postCells.add(cell);
    }
  }

  // Straw decor goes only on cells that no anchor and no solution path claimed.
  final List<int> free = <int>[];
  for (int i = 0; i < count; i++) {
    if (!owned[i]) {
      free.add(i);
    }
  }
  free.shuffle(rng);
  final int strawCount =
      (free.length * (0.12 + rng.nextDouble() * 0.06)).round();
  for (int i = 0; i < strawCount && i < free.length; i++) {
    kinds[free[i]] = CellKind.straw;
  }

  // Scramble to an exact quarter-turn budget inside the band of this scheme.
  final int target =
      scheme.minTurns + rng.nextInt(scheme.maxTurns - scheme.minTurns + 1);
  if (target > postCells.length * 3) {
    return null;
  }
  for (final int cell in postCells) {
    orientation[cell] = solution[cell];
  }
  final List<int> shuffled = List<int>.of(postCells)..shuffle(rng);
  int remaining = target;
  for (int i = 0; i < shuffled.length && remaining > 0; i++) {
    final int left = shuffled.length - i - 1;
    final int maxHere = math.min(3, remaining);
    final int minHere = math.max(1, remaining - 3 * left);
    if (minHere > maxHere) {
      return null;
    }
    final int cost = minHere + rng.nextInt(maxHere - minHere + 1);
    orientation[shuffled[i]] = (solution[shuffled[i]] + 4 - cost) % 4;
    remaining -= cost;
  }
  if (remaining != 0) {
    return null;
  }

  final BoardState board = BoardState(
    cols: cols,
    rows: rows,
    kinds: kinds,
    routeOf: routeOf,
    orientation: orientation,
    solutionOrientation: solution,
    sacks: sacks,
    feeders: feeders,
    parMoves: target,
  );

  // Self-check: replay the stored solution and require three clean links.
  if (!_solutionHolds(board)) {
    return null;
  }
  return board;
}

bool _solutionHolds(BoardState board) {
  final BoardState solved = board.solvedCopy();
  final List<RouteTrace> traces = solved.traceAll();
  return solved.isSolved(traces, solved.crossingsOf(traces));
}

int _directionBetween(int cols, int from, int to) {
  final int dr = (to ~/ cols) - (from ~/ cols);
  final int dc = (to % cols) - (from % cols);
  if (dr < 0) {
    return kDirUp;
  }
  if (dr > 0) {
    return kDirDown;
  }
  if (dc < 0) {
    return kDirLeft;
  }
  return kDirRight;
}

/// Randomised DFS biased toward the target, confined to the interior columns.
List<int>? _carvePath(
  int cols,
  int rows,
  List<bool> owned,
  int start,
  int target,
  math.Random rng,
) {
  final List<int> path = <int>[start];
  final Set<int> used = <int>{start};
  final int targetRow = target ~/ cols;
  final int targetCol = target % cols;
  int expansions = 0;

  bool walk(int current) {
    if (current == target) {
      return true;
    }
    if (expansions++ > 2500) {
      return false;
    }
    final int row = current ~/ cols;
    final int col = current % cols;
    final List<int> options = <int>[];
    for (int dir = 0; dir < 4; dir++) {
      final int nextRow = row + kDirRow[dir];
      final int nextCol = col + kDirCol[dir];
      if (nextRow < 0 || nextRow >= rows || nextCol < 1 || nextCol > cols - 2) {
        continue;
      }
      final int next = nextRow * cols + nextCol;
      if (owned[next] || used.contains(next)) {
        continue;
      }
      options.add(next);
    }
    // Bias toward the target, but with enough noise that trails wind instead
    // of collapsing into three straight lanes.
    final Map<int, int> score = <int, int>{};
    for (final int option in options) {
      final int distance = (option ~/ cols - targetRow).abs() +
          (option % cols - targetCol).abs();
      score[option] = distance * 2 + rng.nextInt(5);
    }
    options.sort((int a, int b) => score[a]!.compareTo(score[b]!));
    for (final int next in options) {
      path.add(next);
      used.add(next);
      if (walk(next)) {
        return true;
      }
      path.removeLast();
      used.remove(next);
    }
    return false;
  }

  if (!walk(start)) {
    return null;
  }
  return path;
}

/// Guaranteed-valid board of three straight lanes. Only reached when every
/// randomised attempt failed, which keeps a dead board impossible to ship.
BoardState _straightFallback(SchemeDef scheme) {
  final int cols = scheme.cols;
  final int rows = scheme.rows;
  final int count = cols * rows;
  final List<CellKind> kinds = List<CellKind>.filled(count, CellKind.empty);
  final List<int> routeOf = List<int>.filled(count, -1);
  final List<int> orientation = List<int>.filled(count, kDirRight);
  final List<int> solution = List<int>.filled(count, kDirRight);
  final List<int> sacks = <int>[];
  final List<int> feeders = <int>[];
  final List<int> postCells = <int>[];

  final List<int> lanes = <int>[0, rows ~/ 2, rows - 1];
  for (int route = 0; route < 3; route++) {
    final int row = lanes[route];
    final int sack = row * cols;
    final int feeder = row * cols + cols - 1;
    kinds[sack] = CellKind.sack;
    kinds[feeder] = CellKind.feeder;
    routeOf[sack] = route;
    routeOf[feeder] = route;
    sacks.add(sack);
    feeders.add(feeder);
    for (int col = 1; col <= cols - 2; col++) {
      final int cell = row * cols + col;
      kinds[cell] = CellKind.post;
      solution[cell] = kDirRight;
      postCells.add(cell);
    }
  }

  final math.Random rng = math.Random(scheme.seed);
  final int target = math.min(
    scheme.minTurns + rng.nextInt(scheme.maxTurns - scheme.minTurns + 1),
    postCells.length * 3,
  );
  int remaining = target;
  for (int i = 0; i < postCells.length && remaining > 0; i++) {
    final int cost = math.min(remaining, 1 + rng.nextInt(3));
    orientation[postCells[i]] = (solution[postCells[i]] + 4 - cost) % 4;
    remaining -= cost;
  }

  return BoardState(
    cols: cols,
    rows: rows,
    kinds: kinds,
    routeOf: routeOf,
    orientation: orientation,
    solutionOrientation: solution,
    sacks: sacks,
    feeders: feeders,
    parMoves: target - remaining,
  );
}

bool _sameRows(List<int> a, List<int> b) {
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// 3x3 board where two routes share the middle plank, used by rules step 2.
BoardState demoCrossingBoard() {
  const int cols = 3;
  const int rows = 3;
  final List<CellKind> kinds =
      List<CellKind>.filled(cols * rows, CellKind.empty);
  final List<int> routeOf = List<int>.filled(cols * rows, -1);
  final List<int> orientation = List<int>.filled(cols * rows, kDirRight);
  final List<int> solution = List<int>.filled(cols * rows, kDirRight);

  kinds[0] = CellKind.sack;
  routeOf[0] = 0;
  kinds[1] = CellKind.post;
  orientation[1] = kDirDown;
  kinds[4] = CellKind.post;
  orientation[4] = kDirRight;
  kinds[5] = CellKind.feeder;
  routeOf[5] = 0;
  kinds[3] = CellKind.sack;
  routeOf[3] = 1;

  return BoardState(
    cols: cols,
    rows: rows,
    kinds: kinds,
    routeOf: routeOf,
    orientation: orientation,
    solutionOrientation: solution,
    sacks: <int>[0, 3],
    feeders: <int>[5, 5],
    parMoves: 0,
  );
}
