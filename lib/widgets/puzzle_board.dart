import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_logic.dart';
import '../theme.dart';
import 'painters.dart';

const double kBoardPad = 8;
const double kBoardBorder = 2;
const double kBoardFrame = kBoardPad + kBoardBorder;
const double kBoardMax = 380;

/// Wooden framed felt board. The tile size is floored from the inner width, so
/// the rendered board is never wider than the space it was given.
class PuzzleBoard extends StatelessWidget {
  final BoardState state;
  final Map<int, List<int>> routes;
  final void Function(int index) onTapCell;
  final double available;
  final double shakeOffset;
  final bool locked;

  const PuzzleBoard({
    super.key,
    required this.state,
    required this.routes,
    required this.onTapCell,
    required this.available,
    this.shakeOffset = 0,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final double boardMaxW = math.min(available - 32, kBoardMax);
    final double tile =
        ((boardMaxW - 2 * kBoardFrame) / state.cols).floorToDouble();
    final double boardW = tile * state.cols + 2 * kBoardFrame;

    final Map<int, Color> live = <int, Color>{};
    routes.forEach((int pair, List<int> cells) {
      final Color c = AppColors.routes[pair % AppColors.routes.length];
      for (final int idx in cells) {
        live[idx] = c;
      }
    });

    final List<Widget> rows = <Widget>[];
    for (int r = 0; r < state.rows; r++) {
      final List<Widget> cells = <Widget>[];
      for (int c = 0; c < state.cols; c++) {
        final int idx = r * state.cols + c;
        cells.add(
          SizedBox(
            width: tile,
            height: tile,
            child: _buildCell(state.grid[idx], idx, tile, live[idx]),
          ),
        );
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
    }

    return Transform.translate(
      offset: Offset(shakeOffset, 0),
      child: Container(
        width: boardW,
        height: boardW,
        padding: const EdgeInsets.all(kBoardPad),
        decoration: BoxDecoration(
          color: AppColors.wood,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.woodEdge, width: kBoardBorder),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.deep.withValues(alpha: 0.53),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AppColors.felt,
            child: Column(mainAxisSize: MainAxisSize.min, children: rows),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(TileModel t, int idx, double tile, Color? routeColor) {
    final Color pairColor = AppColors.routes[t.pairIndex % AppColors.routes.length];
    if (t.isEndpoint) {
      return EndpointTile(
        isSource: t.kind == TileKind.source,
        color: pairColor,
        size: tile,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: locked ? null : () => onTapCell(idx),
      child: PointerTile(model: t, size: tile, routeColor: routeColor),
    );
  }
}

/// Grain sack (source) or feeder (target) endpoint.
class EndpointTile extends StatelessWidget {
  final bool isSource;
  final Color color;
  final double size;

  const EndpointTile({
    super.key,
    required this.isSource,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Image.asset(
          isSource ? AppAssets.spriteGrainSack : AppAssets.spriteFeeder,
          width: size * 0.62,
          height: size * 0.62,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// A rotatable tin road segment.
class PointerTile extends StatelessWidget {
  final TileModel model;
  final double size;
  final Color? routeColor;

  const PointerTile({
    super.key,
    required this.model,
    required this.size,
    this.routeColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool live = routeColor != null;
    return AnimatedScale(
      scale: live ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: live
              ? AppColors.surface
              : AppColors.surfaceAlt.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: live
                ? routeColor!.withValues(alpha: 0.55)
                : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: AnimatedRotation(
          turns: model.rot / 4,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: CustomPaint(
            painter: PointerPainter(
              kind: model.kind,
              color: routeColor ?? AppColors.pointerIdle,
              live: live,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
