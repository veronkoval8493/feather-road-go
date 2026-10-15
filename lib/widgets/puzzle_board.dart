import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_state.dart';
import '../game/game_config.dart';
import '../theme.dart';
import 'trail_painter.dart';

/// Felt inset inside the wooden frame.
const double kBoardPad = 8;

/// Wooden frame stroke.
const double kBoardBorder = 3;

/// Everything between the outer edge of the board and the first tile.
const double kBoardFrame = kBoardPad + kBoardBorder;

/// Tile size that keeps the board inside the 2px overflow budget.
double boardTileFor(double screenWidth, int cols) {
  final double maxWidth = math.min(screenWidth - 32, 380);
  return ((maxWidth - 2 * kBoardFrame) / cols).floorToDouble();
}

/// Framed felt grid: cell dispatch plus the trail painter.
class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    super.key,
    required this.state,
    required this.traces,
    required this.crossings,
    required this.tile,
    required this.revision,
    this.onTapCell,
    this.trailThickness = 1.0,
    this.showSprites = true,
    this.dimmed = false,
  });

  final BoardState state;
  final List<RouteTrace> traces;
  final Set<int> crossings;
  final double tile;
  final int revision;
  final void Function(int index)? onTapCell;
  final double trailThickness;
  final bool showSprites;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final double gridWidth = tile * state.cols;
    final double gridHeight = tile * state.rows;
    final double boardWidth = gridWidth + 2 * kBoardFrame;
    final double boardHeight = gridHeight + 2 * kBoardFrame;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        children: <Widget>[
          Container(
            width: boardWidth,
            height: boardHeight,
            padding: const EdgeInsets.all(kBoardPad),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[AppColors.woodLight, AppColors.woodDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.woodEdge, width: kBoardBorder),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: gridWidth,
                height: gridHeight,
                color: AppColors.felt,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(painter: _FeltPainter(tile: tile)),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TrailPainter(
                          traces: traces,
                          cols: state.cols,
                          tile: tile,
                          crossings: const <int>{},
                          revision: revision,
                          thickness: trailThickness,
                        ),
                      ),
                    ),
                    _buildGrid(),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: TrailPainter(
                            traces: const <RouteTrace>[],
                            cols: state.cols,
                            tile: tile,
                            crossings: crossings,
                            revision: revision,
                          ),
                        ),
                      ),
                    ),
                    if (dimmed)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: AppColors.ink.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Brass pins — positive insets only, so nothing pokes past the frame.
          const Positioned(left: 14, top: 14, child: _BrassPin()),
          const Positioned(right: 14, top: 14, child: _BrassPin()),
          const Positioned(left: 14, bottom: 14, child: _BrassPin()),
          const Positioned(right: 14, bottom: 14, child: _BrassPin()),
        ],
      ),
    );
  }

  Widget _buildGrid() {
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
                  child: _cell(state.indexOf(row, col)),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(int index) {
    final CellKind kind = state.kinds[index];
    switch (kind) {
      case CellKind.sack:
        return _AnchorCell(
          asset: AppAssets.spriteSack,
          color: AppColors.routes[state.routeOf[index]],
          tile: tile,
          showSprite: showSprites,
          showDot: false,
        );
      case CellKind.feeder:
        return _AnchorCell(
          asset: AppAssets.spriteFeeder,
          color: AppColors.routes[state.routeOf[index]],
          tile: tile,
          showSprite: showSprites,
          showDot: true,
        );
      case CellKind.post:
        return SignpostCell(
          key: ValueKey<int>(index),
          orientation: state.orientation[index],
          tile: tile,
          showSprite: showSprites,
          onTap: onTapCell == null ? null : () => onTapCell!(index),
        );
      case CellKind.straw:
        return _StrawCell(tile: tile);
      case CellKind.empty:
        return const SizedBox.shrink();
    }
  }
}

class _BrassPin extends StatelessWidget {
  const _BrassPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[AppColors.brassLight, AppColors.brassDark],
        ),
      ),
    );
  }
}

class _FeltPainter extends CustomPainter {
  const _FeltPainter({required this.tile});

  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (double x = tile; x < size.width; x += tile) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = tile; y < size.height; y += tile) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_FeltPainter oldDelegate) => oldDelegate.tile != tile;
}

/// Grain sack and feeder share one renderer: both are fixed anchors tinted to
/// their route colour.
class _AnchorCell extends StatelessWidget {
  const _AnchorCell({
    required this.asset,
    required this.color,
    required this.tile,
    required this.showSprite,
    required this.showDot,
  });

  final String asset;
  final Color color;
  final double tile;
  final bool showSprite;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(tile * 0.08),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showDot)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 2, bottom: 1),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              if (showSprite)
                ColorFiltered(
                  colorFilter: ColorFilter.mode(color, BlendMode.modulate),
                  child: Image.asset(
                    asset,
                    width: tile * 0.56,
                    height: tile * 0.56,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Container(
                  width: tile * 0.3,
                  height: tile * 0.3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rotatable signpost. One short controller per cell, created and disposed
/// with the cell.
class SignpostCell extends StatefulWidget {
  const SignpostCell({
    super.key,
    required this.orientation,
    required this.tile,
    required this.showSprite,
    this.onTap,
  });

  final int orientation;
  final double tile;
  final bool showSprite;
  final VoidCallback? onTap;

  @override
  State<SignpostCell> createState() => _SignpostCellState();
}

class _SignpostCellState extends State<SignpostCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _turns;
  late double _from;
  late double _to;

  @override
  void initState() {
    super.initState();
    _from = widget.orientation * 0.25;
    _to = _from;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.rotateMs),
      value: 1,
    );
    _turns = AlwaysStoppedAnimation<double>(_to);
  }

  @override
  void didUpdateWidget(covariant SignpostCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      final int steps = (widget.orientation - oldWidget.orientation) % 4;
      _from = _to;
      _to = _from + 0.25 * (steps == 0 ? 4 : steps);
      _turns = Tween<double>(begin: _from, end: _to).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double tile = widget.tile;
    return Padding(
      padding: EdgeInsets.all(tile * 0.1),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.plate,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.plateEdge, width: 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: RotationTransition(
                turns: _turns,
                child: widget.showSprite
                    ? Image.asset(
                        AppAssets.spriteSignpost,
                        width: tile * 0.6,
                        height: tile * 0.6,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        size: tile * 0.5,
                        color: AppColors.woodEdge,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StrawCell extends StatelessWidget {
  const _StrawCell({required this.tile});

  final double tile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(tile * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.feltDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(painter: const _StrawPainter()),
      ),
    );
  }
}

class _StrawPainter extends CustomPainter {
  const _StrawPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    const double pitch = 6;
    for (double x = 0; x < size.width + size.height; x += pitch) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StrawPainter oldDelegate) => false;
}
