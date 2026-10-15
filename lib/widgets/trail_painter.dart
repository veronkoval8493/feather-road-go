import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../game/board_state.dart';
import '../theme.dart';

/// Draws the three grain trails over the felt: a wide soft glow pass, the main
/// stroke, and a dashed pass for a route that currently dead-ends.
class TrailPainter extends CustomPainter {
  const TrailPainter({
    required this.traces,
    required this.cols,
    required this.tile,
    required this.crossings,
    required this.revision,
    this.thickness = 1.0,
  });

  final List<RouteTrace> traces;
  final int cols;
  final double tile;
  final Set<int> crossings;

  /// Bumped whenever the board changes, so repaint is cheap to decide.
  final int revision;

  /// Win animation thickens the trails.
  final double thickness;

  Offset _center(int cell) {
    final int row = cell ~/ cols;
    final int col = cell % cols;
    return Offset((col + 0.5) * tile, (row + 0.5) * tile);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int route = 0; route < traces.length; route++) {
      final RouteTrace trace = traces[route];
      if (trace.cells.length < 2) {
        continue;
      }
      final Color color = AppColors.routes[route % AppColors.routes.length];
      final Path path = Path()..moveTo(_center(trace.cells.first).dx, _center(trace.cells.first).dy);
      for (int i = 1; i < trace.cells.length; i++) {
        final Offset point = _center(trace.cells[i]);
        path.lineTo(point.dx, point.dy);
      }

      final double width = tile * 0.17 * thickness;
      final Paint glow = Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 1.9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, glow);

      if (trace.linked) {
        final Paint main = Paint()
          ..color = color.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, main);
      } else {
        // Unfinished route: dashed, and the last leg warns in terracotta.
        final Paint dashed = Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        _drawDashed(canvas, path, dashed);

        final Offset tip = _center(trace.cells.last);
        canvas.drawCircle(
          tip,
          width * 0.9,
          Paint()..color = AppColors.terracotta.withValues(alpha: 0.9),
        );
      }

      // Origin pip so an empty board still reads as three routes.
      canvas.drawCircle(
        _center(trace.cells.first),
        width * 0.7,
        Paint()..color = color,
      );
    }

    final Paint ring = Paint()
      ..color = AppColors.terracotta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final int cell in crossings) {
      canvas.drawCircle(_center(cell), tile * 0.34, ring);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const double dash = 9;
    const double gap = 7;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(TrailPainter oldDelegate) =>
      oldDelegate.revision != revision ||
      oldDelegate.thickness != thickness ||
      oldDelegate.tile != tile;
}
