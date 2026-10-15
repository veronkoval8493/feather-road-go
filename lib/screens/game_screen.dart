import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_state.dart';
import '../game/game_config.dart';
import '../game/progress_store.dart';
import '../game/scheme_generator.dart';
import '../game/schemes.dart';
import '../theme.dart';
import '../widgets/puzzle_board.dart';
import '../widgets/stat_cell.dart';
import '../widgets/wood_button.dart';

/// Archetype G3 — split panel: header, felt board, stat strip, single CTA.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.scheme,
    required this.schemeIndex,
    required this.onExit,
    required this.onFinish,
  });

  final SchemeDef scheme;
  final int schemeIndex;
  final VoidCallback onExit;
  final void Function(RoundResult result) onFinish;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late BoardState _board;
  late List<RouteTrace> _traces;
  late Set<int> _crossings;
  late int _movesLeft;
  late int _assistStepMs;

  int _checksLeft = AppConfig.checksPerRound;
  int _revision = 0;
  bool _checking = false;
  bool _finished = false;
  bool _won = false;

  Timer? _assist;
  Timer? _idle;
  Timer? _hold;
  Timer? _reveal;

  late final AnimationController _shake;
  late final AnimationController _winGlow;

  @override
  void initState() {
    super.initState();
    _board = generateBoard(widget.scheme);
    _movesLeft = _board.parMoves + AppConfig.moveSlack;
    _retrace();

    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _winGlow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    // Pace the assist so its last turn plus the verdict always lands before the
    // idle backstop, even on the 6x6 schemes.
    final int budget =
        AppConfig.idleResolveMs - AppConfig.assistStartMs - 6000;
    final int turns = math.max(1, _board.remainingSolutionTurns());
    _assistStepMs = math.max(
      800,
      math.min(AppConfig.assistStepMs, budget ~/ (turns + 1)),
    );

    _assist = Timer(
      const Duration(milliseconds: AppConfig.assistStartMs),
      _assistTick,
    );
    // Absolute backstop from mount — deliberately never re-armed, so a stream
    // of taps cannot starve the result frame.
    _idle = Timer(
      const Duration(milliseconds: AppConfig.idleResolveMs),
      _idleResolve,
    );
  }

  @override
  void dispose() {
    _assist?.cancel();
    _idle?.cancel();
    _hold?.cancel();
    _reveal?.cancel();
    _shake.dispose();
    _winGlow.dispose();
    super.dispose();
  }

  void _retrace() {
    _traces = _board.traceAll();
    _crossings = _board.crossingsOf(_traces);
    _revision++;
  }

  bool get _allLinked => _board.isSolved(_traces, _crossings);

  int get _movesUsed => _board.parMoves + AppConfig.moveSlack - _movesLeft;

  void _rotate(int index) {
    if (_finished || _checking || !_board.isRotatable(index)) {
      return;
    }
    setState(() {
      _board.rotate(index);
      _movesLeft = math.max(0, _movesLeft - 1);
      _retrace();
    });
    if (_movesLeft == 0 && !_allLinked) {
      _reveal?.cancel();
      _reveal = Timer(
        const Duration(milliseconds: 600),
        () => _finish(won: false, outOfMoves: true),
      );
    }
  }

  void _handleTap(int index) {
    if (!_board.isRotatable(index)) {
      return;
    }
    _rotate(index);
    // A human is playing: push the assist back so it never takes their turn.
    _assist?.cancel();
    _assist = Timer(
      const Duration(milliseconds: AppConfig.assistStartMs),
      _assistTick,
    );
  }

  void _assistTick() {
    if (!mounted || _finished) {
      return;
    }
    final int index = _board.firstUnsolvedPost();
    if (index == -1) {
      _runCheck();
      return;
    }
    _rotate(index);
    if (_board.firstUnsolvedPost() == -1) {
      _assist = Timer(const Duration(milliseconds: 800), _assistTick);
    } else {
      _assist = Timer(Duration(milliseconds: _assistStepMs), _assistTick);
    }
  }

  void _idleResolve() {
    if (!mounted || _finished) {
      return;
    }
    _finish(won: _allLinked, outOfMoves: false);
  }

  void _runCheck() {
    if (_finished || _checking) {
      return;
    }
    setState(() => _checking = true);
    _reveal?.cancel();
    _reveal = Timer(
      const Duration(milliseconds: AppConfig.checkRevealMs),
      () {
        if (!mounted || _finished) {
          return;
        }
        if (_allLinked) {
          _finish(won: true, outOfMoves: false);
          return;
        }
        setState(() {
          _checking = false;
          _checksLeft = math.max(0, _checksLeft - 1);
        });
        _shake.forward(from: 0);
        if (_checksLeft == 0) {
          _finish(won: false, outOfMoves: false);
        }
      },
    );
  }

  void _finish({required bool won, required bool outOfMoves}) {
    if (_finished) {
      return;
    }
    _finished = true;
    _assist?.cancel();
    _idle?.cancel();
    _reveal?.cancel();

    final int stars = won
        ? (_movesUsed <= _board.parMoves
            ? 3
            : _movesUsed <= _board.parMoves + 3
                ? 2
                : 1)
        : 0;
    final int grain =
        won ? 120 * stars + 15 * _movesLeft + 40 * _checksLeft : 0;
    final RoundResult result = RoundResult(
      schemeIndex: widget.schemeIndex,
      won: won,
      stars: stars,
      grain: grain,
      movesUsed: _movesUsed,
      checksLeft: _checksLeft,
      outOfMoves: outOfMoves,
      board: _board,
    );
    ProgressStore.instance.record(result);

    setState(() {
      _won = won;
      _checking = false;
    });
    if (won) {
      _winGlow.forward(from: 0);
    }
    _hold = Timer(
      Duration(
        milliseconds: won ? AppConfig.winHoldMs : AppConfig.loseHoldMs,
      ),
      () => widget.onFinish(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Column(
        children: <Widget>[
          _header(),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double byWidth = boardTileFor(screenWidth, _board.cols);
                final double byHeight =
                    ((constraints.maxHeight - 2 * kBoardFrame - 24) /
                            _board.rows)
                        .floorToDouble();
                final double tile = math.max(28, math.min(byWidth, byHeight));
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(
                      AppAssets.bgGame,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: AppColors.felt),
                    ),
                    ColoredBox(
                      color: AppColors.surface.withValues(alpha: 0.18),
                    ),
                    Center(
                      child: AnimatedBuilder(
                        animation: _winGlow,
                        builder: (BuildContext context, Widget? child) {
                          return PuzzleBoard(
                            state: _board,
                            traces: _traces,
                            crossings: _crossings,
                            tile: tile,
                            revision: _revision,
                            onTapCell: _handleTap,
                            trailThickness: 1.0 + 0.35 * _winGlow.value,
                            dimmed: _finished && !_won,
                          );
                        },
                      ),
                    ),
                    if (_finished) _verdictOverlay(),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _statStrip(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: WoodButton(
                    label: _allLinked ? 'FEED THE YARD' : 'CHECK ROUTES',
                    icon: Icons.rule_rounded,
                    height: 58,
                    gradient: _allLinked
                        ? const LinearGradient(
                            colors: <Color>[
                              AppColors.gold,
                              AppColors.goldDeep,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: <Color>[
                              AppColors.sage,
                              AppColors.sageDeep,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderColor:
                        _allLinked ? AppColors.goldEdge : AppColors.sageEdge,
                    shadowColor:
                        _allLinked ? AppColors.terracotta : AppColors.sage,
                    onTap: _runCheck,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 44),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(
          bottom: BorderSide(color: Color(0x59F2C64A), width: 2),
        ),
      ),
      child: SizedBox(
        height: 72,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 6),
            SizedBox(
              width: 44,
              height: 44,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.onExit,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 22,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.scheme.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.scheme.sizeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppColors.gold.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'MOVES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.surface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '$_movesLeft',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: _movesLeft <= 3
                          ? AppColors.terracotta
                          : AppColors.gold,
                      fontFeatures: kTabular,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statStrip() {
    final int linked =
        _traces.where((RouteTrace trace) => trace.linked).length;
    return AnimatedBuilder(
      animation: _shake,
      builder: (BuildContext context, Widget? child) {
        final double shift =
            math.sin(_shake.value * math.pi * 3) * 6 * (1 - _shake.value);
        return Transform.translate(offset: Offset(shift, 0), child: child);
      },
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: 0.92),
          border: Border(
            top: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: StatCell(
                label: 'MOVES',
                value: '$_movesLeft',
                valueColor:
                    _movesLeft <= 3 ? AppColors.terracotta : AppColors.gold,
              ),
            ),
            _divider(),
            Expanded(
              child: StatCell(
                label: 'CHECKS',
                valueColor: AppColors.sage,
                dots: <bool>[
                  for (int i = 0; i < AppConfig.checksPerRound; i++)
                    i < _checksLeft,
                ],
              ),
            ),
            _divider(),
            Expanded(
              child: StatCell(
                label: 'LINKED',
                value: '$linked/${_board.sacks.length}',
                valueColor: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: AppColors.surface.withValues(alpha: 0.12),
    );
  }

  Widget _verdictOverlay() {
    final Color accent = _won ? AppColors.gold : AppColors.terracotta;
    return IgnorePointer(
      child: Container(
        color: AppColors.ink.withValues(alpha: 0.42),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                AppAssets.spriteGrain,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Text(
                _won ? 'ROUTES LINKED' : 'NO LUCK',
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                AppAssets.spriteGrain,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
