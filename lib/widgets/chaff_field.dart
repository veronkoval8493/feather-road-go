import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Static drift of wheat chaff behind the loader mark. Deliberately not
/// animated: a perpetual ticker on the splash keeps the window non-idle and
/// stalls the screenshot tooling.
class ChaffField extends CustomPainter {
  const ChaffField({this.count = 34, this.seed = 7});

  final int count;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rng = math.Random(seed);
    for (int i = 0; i < count; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * size.height;
      final double radius = 1.0 + rng.nextDouble() * 1.6;
      final double alpha = 0.10 + rng.nextDouble() * 0.12;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColors.gold.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(ChaffField oldDelegate) =>
      oldDelegate.count != count || oldDelegate.seed != seed;
}
