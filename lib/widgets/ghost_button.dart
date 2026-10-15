import 'package:flutter/material.dart';

import '../theme.dart';

/// Secondary action: quiet felt surface, same icon discipline as [WoodButton].
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 50,
    this.labelColor = AppColors.slate,
    this.fillColor = AppColors.ink,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final Color labelColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fillColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fillColor.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 20, color: labelColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    height: 20 / 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: labelColor,
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
