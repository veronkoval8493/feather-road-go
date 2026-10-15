import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/progress_store.dart';
import '../theme.dart';
import '../widgets/ghost_button.dart';
import '../widgets/mini_board.dart';
import '../widgets/stat_card.dart';
import '../widgets/wood_button.dart';

/// Verdict screen for both outcomes. Same world as the menu, clearly not the
/// same frame: the yard art is blurred behind a deep scrim.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.result,
    required this.schemeTitle,
    required this.bestGrain,
    required this.onPlayAgain,
    required this.onSchemes,
    required this.onHome,
  });

  final RoundResult result;
  final String schemeTitle;
  final int bestGrain;
  final VoidCallback onPlayAgain;
  final VoidCallback onSchemes;
  final VoidCallback onHome;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Animation<double> _starScale(int index) {
    final double start = 0.18 * index;
    return CurvedAnimation(
      parent: _entry,
      curve: Interval(start, start + 0.58, curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RoundResult result = widget.result;
    final bool won = result.won;
    final String heading = won
        ? 'YARD FED!'
        : result.outOfMoves
            ? 'OUT OF MOVES'
            : 'INSPECTION FAILED';
    final Color headingColor =
        won ? AppColors.sageEdge : AppColors.terracotta;

    final int best =
        widget.bestGrain > result.grain ? widget.bestGrain : result.grain;
    final List<int> values = <int>[result.grain, result.movesUsed, best];
    final int nonZero = values.where((int value) => value > 0).length;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Image.asset(
              AppAssets.bgMenu,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.inkSoft),
            ),
          ),
          ColoredBox(color: AppColors.ink.withValues(alpha: 0.78)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.surfaceEdge,
                        width: 2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.5),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _ribbon(),
                        const SizedBox(height: 14),
                        Text(
                          heading,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (int i = 0; i < 3; i++)
                              ScaleTransition(
                                scale: _starScale(i),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 36,
                                    color: i < result.stars
                                        ? AppColors.gold
                                        : AppColors.ink
                                            .withValues(alpha: 0.14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (nonZero >= 2)
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: StatCard(
                                  value: '${result.grain}',
                                  label: 'GRAIN',
                                  valueColor: AppColors.gold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  value: '${result.movesUsed}',
                                  label: 'MOVES USED',
                                  valueColor: AppColors.teal,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatCard(
                                  value: '$best',
                                  label: 'BEST',
                                  valueColor: AppColors.sage,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'MOVES USED ${result.movesUsed}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 16),
                        MiniBoard(
                          state: result.board.solvedCopy(),
                          tile: 22,
                          trailsOnly: true,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'THE ROUTE THAT FEEDS THE YARD',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        WoodButton(
                          label: 'PLAY AGAIN',
                          icon: Icons.refresh_rounded,
                          height: 58,
                          onTap: widget.onPlayAgain,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: GhostButton(
                                label: 'FARM MAP',
                                icon: Icons.map_outlined,
                                height: 48,
                                onTap: widget.onSchemes,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GhostButton(
                                label: 'HOME',
                                icon: Icons.home_rounded,
                                height: 48,
                                onTap: widget.onHome,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ribbon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            AppAssets.icon,
            width: 22,
            height: 22,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.schemeTitle,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
