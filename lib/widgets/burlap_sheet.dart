import 'package:flutter/material.dart';

import '../theme.dart';

/// Cream burlap surface: woven hatch, top highlight, warm drop shadow.
class BurlapSheet extends StatelessWidget {
  const BurlapSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 26),
    this.topRadius = 30,
    this.bottomRadius = 0,
  });

  final Widget child;
  final EdgeInsets padding;
  final double topRadius;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.vertical(
      top: Radius.circular(topRadius),
      bottom: Radius.circular(bottomRadius),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border(
          top: BorderSide(color: AppColors.surfaceEdge, width: 2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(painter: const WeavePainter()),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// 2px diagonal hatch at 7px pitch — burlap weave at the edge of perception.
class WeavePainter extends CustomPainter {
  const WeavePainter({this.color = AppColors.ink, this.opacity = 0.035});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 2;
    const double pitch = 7;
    for (double x = 0; x < size.width + size.height; x += pitch) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(WeavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
