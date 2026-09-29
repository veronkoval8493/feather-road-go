import 'package:flutter/material.dart';

import '../theme.dart';
import 'buttons.dart';

/// 72px header plus the 44px status-bar inset every screen must reserve.
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool onDark;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.onDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.only(top: 44, left: 12, right: 12),
      decoration: BoxDecoration(
        color: onDark
            ? AppColors.deepDark.withValues(alpha: 0.55)
            : AppColors.surface.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: onDark
                ? AppColors.surface.withValues(alpha: 0.10)
                : AppColors.surfaceBorder,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 48,
            child: onBack == null
                ? null
                : RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: onBack!,
                    onDark: onDark,
                  ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: onDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Natural width, so a long counter never overflows the row.
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tin pill used in headers for counters (moves, stars collected).
class HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;

  const HeaderPill({
    super.key,
    required this.icon,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textOnDark,
            ),
          ),
        ],
      ),
    );
  }
}
