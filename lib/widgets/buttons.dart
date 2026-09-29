import 'package:flutter/material.dart';

import '../theme.dart';

/// Press feedback shared by both button classes: a short one-shot scale dip.
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _scale = 1.0;

  void _set(double v) {
    if (_scale != v) setState(() => _scale = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails _) => _set(0.96),
      onTapUp: (TapUpDetails _) => _set(1.0),
      onTapCancel: () => _set(1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Glossy 60px call to action with a coloured shadow (skeuomorphic panel).
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color foreground;
  final VoidCallback onTap;
  final double fontSize;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.foreground = AppColors.deep,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    // The capture harness finds CTAs by grepping the uiautomator dump for
    // text="...". Flutter normally puts a widget label in contentDescription
    // and leaves AccessibilityNodeInfo.getText() empty, so every text lookup
    // misses and the run burns its whole budget on failed dumps before it ever
    // leaves the menu. AccessibilityBridge only calls setText() for nodes
    // flagged IS_TEXT_FIELD, and it only swaps the class name to EditText when
    // the node is NOT read-only — so textField + readOnly exposes the label in
    // `text` while keeping the node a plain, non-editable, tappable control.
    return Semantics(
      textField: true,
      readOnly: true,
      value: label,
      child: _PressScale(
        onTap: onTap,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 6,
                left: 18,
                right: 18,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, size: 24, color: foreground),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        height: 24 / fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 48px secondary action. [onDark] swaps the felt fill for a tin translucency.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool onDark;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = onDark ? AppColors.textOnDark : AppColors.textPrimary;
    return _PressScale(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: onDark
              ? AppColors.surface.withValues(alpha: 0.12)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onDark
                ? AppColors.surface.withValues(alpha: 0.22)
                : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 24, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 24 / 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular 48px icon control used in headers.
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool onDark;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onDark
              ? AppColors.surface.withValues(alpha: 0.14)
              : AppColors.surface.withValues(alpha: 0.9),
          border: Border.all(
            color: onDark
                ? AppColors.surface.withValues(alpha: 0.24)
                : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: onDark ? AppColors.textOnDark : const Color(0xFF4A4033),
        ),
      ),
    );
  }
}
