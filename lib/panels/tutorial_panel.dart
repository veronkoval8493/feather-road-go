import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_state.dart';
import '../game/scheme_generator.dart';
import '../theme.dart';
import '../widgets/mini_board.dart';
import '../widgets/wood_button.dart';
import 'scheme_select_panel.dart';

/// Three rules, each shown on a live mini board rather than described.
class TutorialPanel extends StatefulWidget {
  const TutorialPanel({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<TutorialPanel> createState() => _TutorialPanelState();
}

class _TutorialPanelState extends State<TutorialPanel> {
  late final BoardState _rotateDemo;
  late final BoardState _crossDemo;
  Timer? _ticker;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _rotateDemo = demoBoard();
    _crossDemo = demoCrossingBoard();
    // Bounded demo: four quarter-turns, then the panel settles so the UI tree
    // can be dumped.
    _ticker = Timer.periodic(const Duration(milliseconds: 1400), (Timer timer) {
      if (!mounted || _ticks >= 4) {
        timer.cancel();
        return;
      }
      setState(() {
        _rotateDemo.rotate(4);
        _ticks++;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            AppAssets.bgGame,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.inkSoft),
          ),
          ColoredBox(color: AppColors.ink.withValues(alpha: 0.82)),
          Column(
            children: <Widget>[
              PanelHeader(title: 'GAME RULES', onBack: widget.onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    children: <Widget>[
                      _step(
                        step: 1,
                        title: 'TAP A SIGN',
                        copy: 'Every tap turns a signpost a quarter-turn and '
                            'the grain trail redraws itself.',
                        visual: MiniBoard(
                          state: _rotateDemo,
                          tile: 24,
                          revision: _ticks,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _step(
                        step: 2,
                        title: 'TRAILS MUST NOT CROSS',
                        copy: 'Two trails sharing one plank are marked in red. '
                            'Give each sack its own way through.',
                        visual: MiniBoard(state: _crossDemo, tile: 24),
                      ),
                      const SizedBox(height: 12),
                      _step(
                        step: 3,
                        title: 'CHECK WHEN READY',
                        copy: 'You carry three inspections. A wrong one costs '
                            'a dot, never a move.',
                        visual: _checkDots(),
                      ),
                      const SizedBox(height: 18),
                      WoodButton(
                        label: 'BACK TO YARD',
                        icon: Icons.home_rounded,
                        height: 56,
                        onTap: widget.onBack,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step({
    required int step,
    required String title,
    required String copy,
    required Widget visual,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceEdge, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 90, child: Center(child: visual)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$step · $title',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  copy,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkDots() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < 3; i++)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < 2
                      ? AppColors.sage
                      : AppColors.ink.withValues(alpha: 0.08),
                  border: Border.all(
                    color: i < 2
                        ? AppColors.sageEdge
                        : AppColors.ink.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '2 OF 3 LEFT',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
