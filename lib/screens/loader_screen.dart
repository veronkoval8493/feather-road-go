import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/chaff_field.dart';

/// Branded splash. The hand-off is armed from the first rasterised frame, so a
/// slow first paint cannot swallow the loader entirely; every animation settles
/// inside the first ~1.2s so the window goes idle well before the hand-off.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _discScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _progress;
  late final Animation<double> _sway;

  Timer? _handoff;
  Timer? _safety;
  bool _armed = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.loaderIntroMs),
    );
    _discScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.57, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 0.75, curve: Curves.easeOut),
    );
    _progress = Tween<double>(begin: 0.04, end: 0.98).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOut),
    );
    _sway = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.055, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.03)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.03, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1,
      ),
    ]).animate(_intro);
    _intro.forward();

    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    _safety = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs * 5),
      _finish,
    );
  }

  void _onFrameTimings(List<ui.FrameTiming> timings) {
    if (_armed) {
      return;
    }
    _armed = true;
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    _handoff = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs),
      _finish,
    );
  }

  void _finish() {
    if (_done) {
      return;
    }
    _done = true;
    _handoff?.cancel();
    _safety?.cancel();
    if (mounted) {
      widget.onDone();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTimings);
    _handoff?.cancel();
    _safety?.cancel();
    _intro.dispose();
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
            AppAssets.bgLoader,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.ink.withValues(alpha: 0.88),
                  AppColors.ink.withValues(alpha: 0.96),
                ],
              ),
            ),
          ),
          const CustomPaint(painter: ChaffField()),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ScaleTransition(
                    scale: _discScale,
                    child: Container(
                      width: 176,
                      height: 176,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: <Color>[AppColors.inkSoft, AppColors.ink],
                        ),
                        border: Border.all(color: AppColors.gold, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.26),
                            blurRadius: 42,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: RotationTransition(
                          turns: _sway,
                          child: Image.asset(
                            AppAssets.spriteSignpost,
                            width: 148,
                            height: 148,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const Icon(
                              Icons.signpost_rounded,
                              size: 92,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  FadeTransition(
                    opacity: _titleFade,
                    child: AnimatedBuilder(
                      animation: _titleFade,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.translate(
                          offset: Offset(0, 18 * (1 - _titleFade.value)),
                          child: child,
                        );
                      },
                      child: Column(
                        children: <Widget>[
                          Text(
                            'FEATHER ROAD GO',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                              shadows: const <Shadow>[
                                Shadow(
                                  color: AppColors.ink,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'CHICKEN ROAD · YARD PUZZLE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.4,
                              color: AppColors.gold.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  SizedBox(
                    width: 196,
                    height: 7,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: ColoredBox(
                              color:
                                  AppColors.surface.withValues(alpha: 0.12),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (BuildContext context, Widget? child) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 196 * _progress.value,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        AppColors.gold,
                                        AppColors.terracotta,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
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
        ],
      ),
    );
  }
}
