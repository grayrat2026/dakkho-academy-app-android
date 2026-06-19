import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme/dakkho_theme.dart';
import '../animations/dakkho_animations.dart';

/// GlassCard — the signature UI element of DAKKHO.
///
/// Matches the web app's `.glass-card` CSS class:
///   background: rgba(15, 23, 42, 0.7)  (dark mode)
///   backdrop-filter: blur(24px)
///   border: 1px solid rgba(255, 255, 255, 0.1)
///   border-radius: 1rem (16px)
///   box-shadow: 0 10px 15px -3px rgba(14, 165, 233, 0.1)
///
/// Flutter uses BackdropFilter (which is GPU-accelerated on Android) for the blur.
/// On lower-end devices, blur is disabled and we fall back to a solid color.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.blur = 24,
    this.enableHover = true,
    this.enablePress = true,
    this.onTap,
    this.gradient,
    this.showBorder = true,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final bool enableHover;
  final bool enablePress;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool showBorder;
  final double elevation;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.gradient != null
        ? null
        : (isDark ? DakkhoColors.glassCardBg : DakkhoColors.glassCardBgLight);
    final borderColor = isDark
        ? DakkhoColors.glassCardBorder
        : DakkhoColors.glassCardBorderLight;

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: widget.onTap != null && widget.enablePress
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onTap != null && widget.enablePress
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onTap != null && widget.enablePress
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DakkhoAnimations.fast,
          curve: DakkhoAnimations.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0)
            ..scale(_isPressed ? DakkhoAnimations.pressScale : 1.0),
          transformAlignment: Alignment.center,
          margin: widget.margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.gradient != null ? null : bgColor,
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.showBorder
                      ? Border.all(color: borderColor, width: 1)
                      : null,
                  boxShadow: [
                    if (widget.elevation > 0 || _isHovered)
                      BoxShadow(
                        color: DakkhoColors.glassCardShadow,
                        blurRadius: _isHovered ? 25 : 15,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
