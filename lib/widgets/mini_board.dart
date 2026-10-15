import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/board_state.dart';
import '../theme.dart';
import 'trail_painter.dart';

/// Small felt board used by the rules panel and the result preview. Trails and
/// flat markers only — no sprites, so it stays readable at 20-30px per tile.
class MiniBoard extends StatelessWidget {
  const MiniBoard({
    super.key,
    required this.state,
    required this.tile,
    this.trailsOnly = false,
    this.revision = 0,
  });

  final BoardState state;
  final double tile;
  final bool trailsOnly;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final List<RouteTrace> traces = state.traceAll();
    final Set<int> crossings = state.crossingsOf(traces);
    final double width = tile * state.cols;
    final double height = tile * state.rows;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.woodLight, AppColors.woodDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.woodEdge, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: width,
          height: height,
          color: AppColors.felt,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: TrailPainter(
                    traces: traces,
                    cols: state.cols,
                    tile: tile,
                    crossings: crossings,
                    revision: revision,
                  ),
                ),
              ),
              if (!trailsOnly) _markers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _markers() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int row = 0; row < state.rows; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int col = 0; col < state.cols; col++)
                SizedBox(
                  width: tile,
                  height: tile,
                  child: _marker(state.indexOf(row, col)),
                ),
            ],
          ),
      ],
    );
  }

  Widget _marker(int index) {
    final CellKind kind = state.kinds[index];
    switch (kind) {
      case CellKind.sack:
      case CellKind.feeder:
        final Color color = AppColors.routes[state.routeOf[index]];
        return Padding(
          padding: EdgeInsets.all(tile * 0.18),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: kind == CellKind.sack ? 0.9 : 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        );
      case CellKind.post:
        return Padding(
          padding: EdgeInsets.all(tile * 0.16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.plate,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.plateEdge),
            ),
            child: Center(
              child: Transform.rotate(
                angle: (state.orientation[index] - kDirRight) * math.pi / 2,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: tile * 0.44,
                  color: AppColors.woodEdge,
                ),
              ),
            ),
          ),
        );
      case CellKind.straw:
        return Padding(
          padding: EdgeInsets.all(tile * 0.2),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.feltDark,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      case CellKind.empty:
        return const SizedBox.shrink();
    }
  }
}
