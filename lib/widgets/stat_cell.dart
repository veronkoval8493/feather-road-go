import 'package:flutter/material.dart';

import '../theme.dart';

/// One cell of the in-game stat strip. Text and colour only — no raster icons,
/// so three cells in a row can never disagree about size.
class StatCell extends StatelessWidget {
  const StatCell({
    super.key,
    required this.label,
    required this.valueColor,
    this.value,
    this.dots,
  });

  final String label;
  final Color valueColor;
  final String? value;

  /// Filled / hollow dot pattern, used by the CHECKS cell.
  final List<bool>? dots;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (dots != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (final bool filled in dots!)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? valueColor
                        : AppColors.surface.withValues(alpha: 0.12),
                    border: Border.all(
                      color: filled
                          ? valueColor
                          : AppColors.surface.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          )
        else
          Text(
            value ?? '',
            style: TextStyle(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: valueColor,
              fontFeatures: kTabular,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: AppColors.surface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
