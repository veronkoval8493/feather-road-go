import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/levels.dart';
import '../theme.dart';
import 'painters.dart';
import 'stat_pill.dart';

class SchemeCard extends StatelessWidget {
  final SchemeModel scheme;
  final List<List<int>> previewRoutes;
  final int stars;
  final bool locked;
  final int difficulty;
  final VoidCallback onTap;

  const SchemeCard({
    super.key,
    required this.scheme,
    required this.previewRoutes,
    required this.stars,
    required this.locked,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> dots = <Widget>[];
    for (int i = 0; i < 3; i++) {
      dots.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < difficulty ? AppColors.orange : AppColors.surfaceBorder,
          ),
        ),
      );
    }

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 76,
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: CustomPaint(
                    painter: MiniBoardPainter(
                      rows: scheme.rows,
                      cols: scheme.cols,
                      routes: previewRoutes,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Image.asset(
                  AppAssets.spriteGrainSack,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${scheme.name} ${scheme.sizeLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: dots),
        const SizedBox(height: 6),
        StarRow(earned: stars, size: 18),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.deep.withValues(alpha: 0.13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: locked
            ? Stack(
                children: <Widget>[
                  Opacity(opacity: 0.45, child: content),
                  const Positioned(
                    right: 2,
                    top: 2,
                    child: Icon(
                      Icons.lock,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : content,
      ),
    );
  }
}
