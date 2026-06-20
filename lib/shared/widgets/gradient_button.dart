import 'package:flutter/material.dart';
import '../../core/theme/dakkho_theme.dart';
import '../animations/dakkho_animations.dart';

/// GradientButton — primary call-to-action button.
///
/// Matches the web app's `.gradient-btn` CSS:
///   background: linear-gradient(135deg, #0ea5e9, #2563eb)
///   color: white
///   border-radius: 0.75rem (12px)
///   transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1)
///   hover: scale(1.02) + box-shadow
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.gradient = DakkhoColors.primaryGradient,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Gradient gradient;
  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: DakkhoAnimations.normal,
          curve: DakkhoAnimations.easeOut,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _isHovered && _isEnabled ? -1 : 0, 0)
            ..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _isEnabled ? widget.gradient : null,
            color: !_isEnabled ? DakkhoColors.surfaceLighter : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (_isEnabled && (_isHovered || _isPressed))
                BoxShadow(
                  color: DakkhoColors.primary.withValues(alpha: _isPressed ? 0.4 : 0.3),
                  blurRadius: _isPressed ? 15 : 25,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: AnimatedSwitcher(
                duration: DakkhoAnimations.fast,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        key: ValueKey('loader'),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontFamilyFallback: ['NotoSansBengali', 'Roboto'],
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
