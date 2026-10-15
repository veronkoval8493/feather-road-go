import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';
import '../widgets/burlap_sheet.dart';
import '../widgets/ghost_button.dart';
import '../widgets/wood_button.dart';

/// Archetype M2 — full-bleed yard art with a burlap bottom sheet.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.onPlay,
    required this.onSchemes,
    required this.onRules,
    required this.schemeCount,
    required this.totalStars,
  });

  final VoidCallback onPlay;
  final VoidCallback onSchemes;
  final VoidCallback onRules;
  final int schemeCount;
  final int totalStars;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) {
    return CurvedAnimation(
      parent: _entry,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double artHeight =
        math.max(190, math.min(height * 0.52, height - 376));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: artHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  AppAssets.bgMenu,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: AppColors.inkSoft),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const <double>[0.0, 0.72, 1.0],
                      colors: <Color>[
                        AppColors.ink.withValues(alpha: 0.18),
                        AppColors.surface.withValues(alpha: 0.0),
                        AppColors.surface,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  bottom: 18,
                  child: FadeTransition(
                    opacity: _stagger(0.0, 0.6),
                    child: Image.asset(
                      AppAssets.spriteHen,
                      width: 148,
                      height: 148,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  top: 52,
                  right: 18,
                  child: Container(
                    width: 92,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.totalStars}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.surface,
                            fontFeatures: kTabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic),
              ),
              child: SafeArea(
                top: false,
                child: BurlapSheet(child: _sheetContent(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetContent(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FadeTransition(
          opacity: _stagger(0.0, 0.5),
          child: Text(
            'FEATHER ROAD GO',
            style: text.headlineMedium?.copyWith(letterSpacing: 1.0),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _stagger(0.12, 0.62),
          child: const Text(
            'ROTATE THE SIGNS · FEED THE YARD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _stagger(0.24, 0.74),
          child: Row(
            children: <Widget>[
              _chip('${widget.schemeCount} SCHEMES'),
              const SizedBox(width: 10),
              _chip(
                widget.totalStars > 0 ? 'BEST ${widget.totalStars} ★' : 'EARN 3 ★',
              ),
            ],
          ),
        ),
        const Spacer(),
        FadeTransition(
          opacity: _stagger(0.36, 0.86),
          child: WoodButton(
            label: 'PLAY',
            icon: Icons.play_arrow_rounded,
            height: 62,
            fontSize: 19,
            onTap: widget.onPlay,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: GhostButton(
                label: 'FARM MAP',
                icon: Icons.map_outlined,
                onTap: widget.onSchemes,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GhostButton(
                label: 'GAME RULES',
                icon: Icons.menu_book_outlined,
                onTap: widget.onRules,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'FOR ENTERTAINMENT ONLY · NO REAL PRIZES',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.goldText,
        ),
      ),
    );
  }
}
