import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/levels.dart';
import '../theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';

/// M2 bottom-sheet menu: farm map art on top, felt sheet with the CTA below.
class MenuScreen extends StatefulWidget {
  final int grain;
  final int selectedScheme;
  final ValueChanged<int> onSelectScheme;
  final VoidCallback onPlay;
  final VoidCallback onSchemes;
  final VoidCallback onTutorial;

  const MenuScreen({
    super.key,
    required this.grain,
    required this.selectedScheme,
    required this.onSelectScheme,
    required this.onPlay,
    required this.onSchemes,
    required this.onTutorial,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<Offset> _sheetSlide;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _heroFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 0.83, curve: Curves.easeOut),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Widget _chip(int schemeIndex, String label) {
    final bool active = widget.selectedScheme == schemeIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelectScheme(schemeIndex),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.orange.withValues(alpha: 0.14)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.orange : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: active ? AppColors.orange : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> chipLabels = <String>[
      'EASY 5×5',
      'FARM 6×6',
      'BARN 7×7',
    ];

    return AppScaffold(
      background: const AssetImage(AppAssets.bgMenu),
      overlay: <Color>[
        AppColors.deep.withValues(alpha: 0.18),
        AppColors.deep.withValues(alpha: 0.42),
      ],
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 16, right: 16),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: RoundIconButton(
                      icon: Icons.settings,
                      onTap: widget.onTutorial,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deep.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.grass,
                            size: 16,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GRAIN ${widget.grain}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.deep.withValues(alpha: 0.33),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.spriteChicken,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: _sheetSlide,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceAlt, width: 6),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.deep.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'FEATHER ROAD GO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TAP A POINTER TO TURN IT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < kMenuChipSchemes.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(width: 8),
                        Flexible(
                          child: _chip(kMenuChipSchemes[i], chipLabels[i]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'PLAY NOW',
                    icon: Icons.play_arrow,
                    gradient: const <Color>[AppColors.gold, AppColors.goldDeep],
                    onTap: widget.onPlay,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryButton(
                          label: 'SCHEMES',
                          icon: Icons.grid_view,
                          onTap: widget.onSchemes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'HOW TO PLAY',
                          icon: Icons.school,
                          onTap: widget.onTutorial,
                        ),
                      ),
                    ],
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
