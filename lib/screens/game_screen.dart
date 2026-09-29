import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_logic.dart';
import '../game/game_config.dart';
import '../game/levels.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/puzzle_board.dart';
import '../widgets/screen_header.dart';
import '../widgets/stat_pill.dart';

/// G3 split panel: header, felt board, stat strip, action row.
class GameScreen extends StatefulWidget {
  final int schemeIndex;
  final ValueChanged<GameResult> onFinish;
  final VoidCallback onBack;

  const GameScreen({
    super.key,
    required this.schemeIndex,
    required this.onFinish,
    required this.onBack,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late BoardState _board;
  late Map<int, List<int>> _routes;
  late final AnimationController _shake;

  Timer? _idleBackstop;
  Timer? _checkTimer;
  Timer? _holdTimer;

  bool _checking = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _reset();
    // Armed once, never re-armed on input: a passive test run still reaches a
    // result frame while the board itself gets plenty of camera time first.
    _idleBackstop = Timer(
      const Duration(milliseconds: GameConfig.idleBackstopMs),
      () => _finish(win: false, holdMs: GameConfig.backstopHoldMs),
    );
  }

  @override
  void dispose() {
    _idleBackstop?.cancel();
    _checkTimer?.cancel();
    _holdTimer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  void _reset() {
    _board = buildBoard(kSchemes[widget.schemeIndex]);
    _routes = completedRoutes(_board);
    _checking = false;
  }

  void _onTapCell(int index) {
    if (_finished || _checking) return;
    final TileModel tile = _board.grid[index];
    if (tile.isEndpoint) return;
    setState(() {
      tile.rot = (tile.rot + 1) % 4;
      _board.movesLeft = math.max(0, _board.movesLeft - 1);
      _routes = completedRoutes(_board);
    });
    if (_board.movesLeft == 0) {
      _runCheck(outOfMoves: true);
    }
  }

  void _runCheck({bool outOfMoves = false}) {
    if (_finished || _checking) return;
    setState(() => _checking = true);
    _checkTimer = Timer(
      const Duration(milliseconds: GameConfig.checkAnimMs),
      () {
        if (!mounted || _finished) return;
        final Map<int, List<int>> done = completedRoutes(_board);
        final bool solved = done.length == _board.pairs;
        setState(() {
          _routes = done;
          _checking = false;
        });
        if (solved) {
          _finish(win: true);
          return;
        }
        _shake.forward(from: 0);
        setState(() => _board.checksLeft = math.max(0, _board.checksLeft - 1));
        if (outOfMoves || _board.checksLeft == 0) {
          _finish(win: false);
        }
      },
    );
  }

  void _finish({required bool win, int? holdMs}) {
    if (_finished || !mounted) return;
    _finished = true;
    _idleBackstop?.cancel();
    final int pairsDone = _routes.length;
    final int movesLeft = _board.movesLeft;
    final List<List<int>> solved =
        completedRoutes(_board.solvedCopy()).values.toList();
    _holdTimer = Timer(
      Duration(milliseconds: holdMs ?? GameConfig.resultHoldMs),
      () {
        if (!mounted) return;
        widget.onFinish(
          GameResult(
            win: win,
            stars: win ? starsFor(_board, movesLeft) : 0,
            schemeIndex: widget.schemeIndex,
            pairsDone: win ? _board.pairs : pairsDone,
            pairsTotal: _board.pairs,
            movesLeft: movesLeft,
            rows: _board.rows,
            cols: _board.cols,
            solvedRoutes: solved,
          ),
        );
      },
    );
  }

  void _restartBoard() {
    if (_finished) return;
    setState(_reset);
  }

  @override
  Widget build(BuildContext context) {
    final SchemeModel scheme = kSchemes[widget.schemeIndex];

    return AppScaffold(
      background: const AssetImage(AppAssets.bgGame),
      overlay: <Color>[
        AppColors.deep.withValues(alpha: 0.82),
        AppColors.deep.withValues(alpha: 0.92),
      ],
      child: Column(
        children: <Widget>[
          ScreenHeader(
            title: '${scheme.name} ${scheme.sizeLabel}',
            onBack: widget.onBack,
            trailing: HeaderPill(
              icon: Icons.autorenew,
              text: '${_board.movesLeft}',
              accent: AppColors.gold,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final double available = math.min(c.maxWidth, c.maxHeight);
                return Center(
                  child: AnimatedBuilder(
                    animation: _shake,
                    builder: (BuildContext context, Widget? child) {
                      final double t = _shake.value;
                      final double dx =
                          math.sin(t * math.pi * 3) * 6 * (1 - t);
                      return PuzzleBoard(
                        state: _board,
                        routes: _routes,
                        onTapCell: _onTapCell,
                        available: available,
                        shakeOffset: dx,
                        locked: _finished || _checking,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.deepDark.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: StatPillRow(
              pills: <StatPill>[
                StatPill(
                  value: '${_board.movesLeft}',
                  label: 'MOVES',
                  accent: AppColors.gold,
                  onDark: true,
                ),
                StatPill(
                  value: '${_board.checksLeft}',
                  label: 'CHECKS',
                  accent: AppColors.orange,
                  onDark: true,
                ),
                StatPill(
                  value: '${_routes.length}/${_board.pairs}',
                  label: 'PAIRS',
                  accent: AppColors.green,
                  onDark: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'CHECK YOUR ROADS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: AppColors.surface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: RoundIconButton(
                          icon: Icons.refresh,
                          onTap: _restartBoard,
                          onDark: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedScale(
                        scale: _checking ? 0.96 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: PrimaryButton(
                          label: 'GO',
                          icon: Icons.check_circle,
                          fontSize: 18,
                          gradient: const <Color>[
                            AppColors.green,
                            AppColors.greenDeep,
                          ],
                          onTap: _runCheck,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
