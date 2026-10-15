import 'package:flutter/material.dart';

import '../theme.dart';

/// The single source of truth for every primary call to action: fixed 24px
/// icon, label line-height matched to the icon, centred row, no Positioned.
class WoodButton extends StatefulWidget {
  const WoodButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient,
    this.borderColor,
    this.shadowColor,
    this.labelColor = AppColors.ink,
    this.height = 58,
    this.fontSize = 17,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? shadowColor;
  final Color labelColor;
  final double height;
  final double fontSize;

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Gradient gradient = widget.gradient ??
        const LinearGradient(
          colors: <Color>[AppColors.gold, AppColors.goldDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    final Color border = widget.borderColor ?? AppColors.goldEdge;
    final Color shadow = widget.shadowColor ?? AppColors.terracotta;

    return AnimatedScale(
      scale: _pressed ? 0.965 : 1.0,
      duration: const Duration(milliseconds: 90),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadow.withValues(alpha: 0.42),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
            onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Stack(
              children: <Widget>[
                // Skeuomorphic top gloss — the highlight that reads as planed,
                // waxed wood rather than a flat fill.
                Positioned(
                  left: 2,
                  right: 2,
                  top: 1,
                  child: Container(
                    height: widget.height * 0.38,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.surface.withValues(alpha: 0.45),
                          AppColors.surface.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (widget.icon != null) ...<Widget>[
                        Icon(widget.icon, size: 24, color: widget.labelColor),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: widget.fontSize,
                          height: 24 / widget.fontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                          color: widget.labelColor,
                        ),
                      ),
                    ],
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
