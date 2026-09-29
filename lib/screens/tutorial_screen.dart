import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/board_logic.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/painters.dart';
import '../widgets/screen_header.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onBegin;

  const TutorialScreen({
    super.key,
    required this.onBack,
    required this.onBegin,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _demoRot = 0;
  int _ticks = 0;
  Timer? _demo;

  @override
  void initState() {
    super.initState();
    // Finite demo: settles after three full turns so the window goes idle.
    _demo = Timer.periodic(const Duration(milliseconds: 1200), (Timer t) {
      if (!mounted) return;
      setState(() {
        _demoRot = (_demoRot + 1) % 4;
        _ticks++;
      });
      if (_ticks >= 12) t.cancel();
    });
  }

  @override
  void dispose() {
    _demo?.cancel();
    super.dispose();
  }

  Widget _step(IconData icon, Color color, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.deep.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      background: const AssetImage(AppAssets.bgGame),
      overlay: <Color>[
        AppColors.deep.withValues(alpha: 0.92),
        AppColors.deepDark.withValues(alpha: 0.95),
      ],
      child: Column(
        children: <Widget>[
          ScreenHeader(title: 'HOW TO PLAY', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        AppAssets.icon,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'LINK EVERY GRAIN SACK TO ITS FEEDER',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          height: 1.35,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _step(
                  Icons.rotate_right,
                  AppColors.cyan,
                  'TAP A POINTER',
                  'Each tap turns the pointer 90 degrees. Every turn costs one move.',
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.felt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < 3; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: 10),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: AnimatedRotation(
                            turns: (i == 1 ? _demoRot : 0) / 4,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: CustomPaint(
                              painter: PointerPainter(
                                kind: i == 1
                                    ? TileKind.elbow
                                    : TileKind.straight,
                                color: i == 1
                                    ? AppColors.gold
                                    : AppColors.pointerIdle,
                                live: i == 1,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _step(
                  Icons.timeline,
                  AppColors.green,
                  'BUILD THE ROAD',
                  'Link every grain sack to the feeder of the same colour. Roads never cross.',
                ),
                _step(
                  Icons.verified,
                  AppColors.gold,
                  'CHECK THE FARM',
                  'Press GO to verify. Three wrong checks end the run.',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: PrimaryButton(
              label: 'START PLAYING',
              icon: Icons.play_arrow,
              gradient: const <Color>[AppColors.green, AppColors.greenDeep],
              onTap: widget.onBegin,
            ),
          ),
        ],
      ),
    );
  }
}
