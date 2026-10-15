/// Board model: cells, orientations, route tracing and round evaluation.
enum CellKind { empty, sack, feeder, post, straw }

/// Orientation indices. 0 = up, 1 = right, 2 = down, 3 = left.
const int kDirUp = 0;
const int kDirRight = 1;
const int kDirDown = 2;
const int kDirLeft = 3;

const List<int> kDirRow = <int>[-1, 0, 1, 0];
const List<int> kDirCol = <int>[0, 1, 0, -1];

/// The outcome of walking one grain route from its sack.
class RouteTrace {
  const RouteTrace({
    required this.cells,
    required this.linked,
    required this.dead,
  });

  /// Cells the trail passes through, sack first.
  final List<int> cells;

  /// Reached its own colour of feeder.
  final bool linked;

  /// Ran into straw, a wall or a loop.
  final bool dead;
}

class BoardState {
  BoardState({
    required this.cols,
    required this.rows,
    required this.kinds,
    required this.routeOf,
    required this.orientation,
    required this.solutionOrientation,
    required this.sacks,
    required this.feeders,
    required this.parMoves,
  });

  final int cols;
  final int rows;

  /// Cell kinds, row-major.
  final List<CellKind> kinds;

  /// Route index for sacks and feeders, -1 everywhere else.
  final List<int> routeOf;

  /// Live orientation of every cell (only posts and sacks read it).
  final List<int> orientation;

  /// Orientation that solves the board, filled for every post.
  final List<int> solutionOrientation;

  /// Cell index of each route's sack / feeder.
  final List<int> sacks;
  final List<int> feeders;

  /// Quarter-turns needed to restore the solution from the scrambled start.
  final int parMoves;

  int get cellCount => cols * rows;

  int indexOf(int row, int col) => row * cols + col;

  int rowOf(int index) => index ~/ cols;

  int colOf(int index) => index % cols;

  bool isRotatable(int index) => kinds[index] == CellKind.post;

  void rotate(int index) {
    if (!isRotatable(index)) {
      return;
    }
    orientation[index] = (orientation[index] + 1) % 4;
  }

  /// First post that is not yet on its solution orientation, or -1.
  int firstUnsolvedPost() {
    for (int i = 0; i < kinds.length; i++) {
      if (kinds[i] == CellKind.post && orientation[i] != solutionOrientation[i]) {
        return i;
      }
    }
    return -1;
  }

  /// Quarter-turns still needed to reach the stored solution.
  int remainingSolutionTurns() {
    int total = 0;
    for (int i = 0; i < kinds.length; i++) {
      if (kinds[i] == CellKind.post) {
        total += (solutionOrientation[i] - orientation[i]) % 4;
      }
    }
    return total;
  }

  RouteTrace traceRoute(int route) {
    final int start = sacks[route];
    final List<int> cells = <int>[start];
    final Set<int> seen = <int>{start};
    int direction = orientation[start];
    int current = start;
    final int maxSteps = cols * rows * 2;

    for (int step = 0; step < maxSteps; step++) {
      final int nextRow = rowOf(current) + kDirRow[direction];
      final int nextCol = colOf(current) + kDirCol[direction];
      if (nextRow < 0 || nextRow >= rows || nextCol < 0 || nextCol >= cols) {
        return RouteTrace(cells: cells, linked: false, dead: true);
      }
      final int next = indexOf(nextRow, nextCol);
      final CellKind kind = kinds[next];
      if (kind == CellKind.straw || kind == CellKind.sack || seen.contains(next)) {
        return RouteTrace(cells: cells, linked: false, dead: true);
      }
      cells.add(next);
      seen.add(next);
      if (kind == CellKind.feeder) {
        return RouteTrace(
          cells: cells,
          linked: routeOf[next] == route,
          dead: false,
        );
      }
      if (kind == CellKind.post) {
        direction = orientation[next];
      }
      current = next;
    }
    return RouteTrace(cells: cells, linked: false, dead: true);
  }

  List<RouteTrace> traceAll() {
    return List<RouteTrace>.generate(sacks.length, traceRoute);
  }

  /// Cells claimed by more than one route.
  Set<int> crossingsOf(List<RouteTrace> traces) {
    final Map<int, int> hits = <int, int>{};
    for (final RouteTrace trace in traces) {
      for (final int cell in trace.cells) {
        hits[cell] = (hits[cell] ?? 0) + 1;
      }
    }
    final Set<int> crossed = <int>{};
    hits.forEach((int cell, int count) {
      if (count > 1) {
        crossed.add(cell);
      }
    });
    return crossed;
  }

  bool isSolved(List<RouteTrace> traces, Set<int> crossed) {
    if (crossed.isNotEmpty) {
      return false;
    }
    for (final RouteTrace trace in traces) {
      if (!trace.linked) {
        return false;
      }
    }
    return true;
  }

  /// Board with every post already on its solution orientation.
  BoardState solvedCopy() {
    return BoardState(
      cols: cols,
      rows: rows,
      kinds: List<CellKind>.of(kinds),
      routeOf: List<int>.of(routeOf),
      orientation: List<int>.generate(
        orientation.length,
        (int i) => kinds[i] == CellKind.post ? solutionOrientation[i] : orientation[i],
      ),
      solutionOrientation: List<int>.of(solutionOrientation),
      sacks: List<int>.of(sacks),
      feeders: List<int>.of(feeders),
      parMoves: parMoves,
    );
  }
}
