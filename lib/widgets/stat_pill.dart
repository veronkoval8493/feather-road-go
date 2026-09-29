import 'package:flutter/material.dart';

import '../theme.dart';

/// The one stat widget used on both the board screen and the result card.
class StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final bool onDark;

  const StatPill({
    super.key,
    required this.value,
    required this.label,
    required this.accent,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.surface.withValues(alpha: 0.10)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accent,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: onDark
                  ? AppColors.surface.withValues(alpha: 0.62)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of three stat pills; rendered only when at least two are visible.
class StatPillRow extends StatelessWidget {
  final List<StatPill> pills;

  const StatPillRow({super.key, required this.pills});

  @override
  Widget build(BuildContext context) {
    if (pills.length < 2) return const SizedBox.shrink();
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < pills.length; i++) {
      if (i > 0) children.add(const SizedBox(width: 10));
      children.add(Expanded(child: pills[i]));
    }
    // IntrinsicHeight gives the row a bounded cross-axis extent, so the pills
    // can stretch to a shared height even inside an unbounded column.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Filled / empty star row (Material glyphs, never emoji).
class StarRow extends StatelessWidget {
  final int earned;
  final double size;
  final bool animated;

  const StarRow({
    super.key,
    required this.earned,
    this.size = 40,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = <Widget>[];
    for (int i = 0; i < 3; i++) {
      final Widget star = Icon(
        Icons.star_rounded,
        size: size,
        color: i < earned ? AppColors.gold : AppColors.surfaceBorder,
      );
      stars.add(
        animated
            ? TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 320 + i * 140),
                curve: Curves.easeOutBack,
                builder: (BuildContext context, double t, Widget? child) =>
                    Transform.scale(scale: t, child: child),
                child: star,
              )
            : star,
      );
      if (i < 2) stars.add(const SizedBox(width: 6));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }
}
