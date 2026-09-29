import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../game/board_logic.dart';
import '../theme.dart';

/// Dense static grain field. Four tinted passes of ~32.5k points each are
/// enough texture to keep the splash frame visually distinct from the menu.
/// Painted exactly once (shouldRepaint is false) so it costs nothing per frame.
class GrainFieldPainter extends CustomPainter {
  const GrainFieldPainter();

  static const int _pointsPerPass = 32500;
  static const List<Color> _tints = <Color>[
    AppColors.gold,
    AppColors.surface,
    AppColors.green,
    AppColors.gold,
  ];
  static const List<double> _alphas = <double>[0.16, 0.13, 0.10, 0.12];

  @override
  void paint(Canvas canvas, Size size) {
    int state = 0x9E3779B9;
    int nextRand() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      state &= 0xFFFFFFFF;
      return state;
    }

    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List pts = Float32List(_pointsPerPass * 2);
      for (int i = 0; i < _pointsPerPass; i++) {
        pts[i * 2] = (nextRand() % 100000) / 100000.0 * size.width;
        pts[i * 2 + 1] = (nextRand() % 100000) / 100000.0 * size.height;
      }
      final Paint paint = Paint()
        ..color = _tints[pass].withValues(alpha: _alphas[pass])
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(PointMode.points, pts, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A single tin road pointer in its base orientation. Rotation is applied by
/// the widget layer, so this painter only knows the shape.
class PointerPainter extends CustomPainter {
  final TileKind kind;
  final Color color;
  final bool live;

  const PointerPainter({
    required this.kind,
    required this.color,
    required this.live,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double thickness = w * 0.18;

    final Path path = Path();
    if (kind == TileKind.straight) {
      path.moveTo(cx, 0);
      path.lineTo(cx, h);
    } else {
      path.moveTo(cx, 0);
      path.lineTo(cx, cy);
      path.lineTo(w, cy);
    }

    if (live) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness + 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = live ? color : AppColors.pointerIdle
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Tin highlight along the stroke.
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.surface.withValues(alpha: live ? 0.42 : 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness * 0.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant PointerPainter old) =>
      old.kind != kind || old.color != color || old.live != live;
}

/// Small felt board preview used on scheme cards and the result card.
class MiniBoardPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<List<int>> routes;

  const MiniBoardPainter({
    required this.rows,
    required this.cols,
    required this.routes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, Paint()..color = AppColors.felt);
    canvas.save();
    canvas.clipRRect(frame);

    final double cw = size.width / cols;
    final double ch = size.height / rows;
    final Paint dot = Paint()..color = AppColors.deep.withValues(alpha: 0.25);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset((c + 0.5) * cw, (r + 0.5) * ch),
          cw * 0.10,
          dot,
        );
      }
    }

    for (int i = 0; i < routes.length; i++) {
      final List<int> cells = routes[i];
      if (cells.length < 2) continue;
      final Color color = AppColors.routes[i % AppColors.routes.length];
      final Path path = Path();
      for (int j = 0; j < cells.length; j++) {
        final int r = cells[j] ~/ cols;
        final int c = cells[j] % cols;
        final Offset p = Offset((c + 0.5) * cw, (r + 0.5) * ch);
        if (j == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = cw * 0.26
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final int first = cells.first;
      final int last = cells.last;
      final Paint cap = Paint()..color = color;
      canvas.drawCircle(
        Offset((first % cols + 0.5) * cw, (first ~/ cols + 0.5) * ch),
        cw * 0.22,
        cap,
      );
      canvas.drawCircle(
        Offset((last % cols + 0.5) * cw, (last ~/ cols + 0.5) * ch),
        cw * 0.22,
        cap,
      );
    }

    canvas.restore();
    canvas.drawRRect(
      frame,
      Paint()
        ..color = AppColors.surfaceBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant MiniBoardPainter old) =>
      old.rows != rows || old.cols != cols || old.routes != routes;
}
