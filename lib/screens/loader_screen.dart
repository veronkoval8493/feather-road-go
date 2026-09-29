import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/painters.dart';

/// Branded splash. The hand-off is driven by a wall-clock Timer, never by an
/// animation listener, because the CI emulator runs with animation scale zero.
class LoaderScreen extends StatefulWidget {
  final VoidCallback onDone;

  const LoaderScreen({super.key, required this.onDone});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.78, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
    );
    _intro.forward();
    _handoff = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs),
      () {
        if (mounted) widget.onDone();
      },
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      background: const AssetImage(AppAssets.bgLoader),
      overlay: <Color>[
        AppColors.deep.withValues(alpha: 0.88),
        AppColors.deepDark.withValues(alpha: 0.94),
      ],
      behindContent: const CustomPaint(painter: GrainFieldPainter()),
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              AppColors.gold.withValues(alpha: 0.22),
                              AppColors.gold.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      Image.asset(
                        AppAssets.spriteSignpost,
                        width: 132,
                        height: 132,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'FEATHER ROAD GO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    color: AppColors.textOnDark,
                    shadows: <Shadow>[
                      Shadow(
                        color: Color(0x9918202A),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'TURN · CONNECT · FEED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.0,
                    color: AppColors.gold.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 190,
                  height: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.05, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      builder: (BuildContext context, double v, Widget? child) {
                        return LinearProgressIndicator(
                          value: v,
                          minHeight: 5,
                          backgroundColor:
                              AppColors.surface.withValues(alpha: 0.16),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.gold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'LOADING…',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                    color: AppColors.surface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
