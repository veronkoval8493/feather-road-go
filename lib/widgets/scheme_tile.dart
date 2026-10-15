import 'package:flutter/material.dart';

import '../theme.dart';

/// One scheme on the farm map.
class SchemeTile extends StatelessWidget {
  const SchemeTile({
    super.key,
    required this.number,
    required this.stars,
    required this.locked,
    required this.onTap,
  });

  final int number;
  final int stars;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: locked ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              color: locked
                  ? AppColors.ink.withValues(alpha: 0.08)
                  : AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: locked
                    ? AppColors.ink.withValues(alpha: 0.15)
                    : AppColors.gold.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (locked)
                  const Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  )
                else
                  Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      fontFeatures: kTabular,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < 3; i++)
                      Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: i < stars
                            ? AppColors.gold
                            : AppColors.ink.withValues(alpha: 0.16),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
