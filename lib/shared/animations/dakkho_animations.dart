import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;

/// DAKKHO Academy — Animation System
///
/// "Millions of Micro Animations" — 7-layer animation framework applied to every screen.
/// Built on top of flutter_animate for declarative chains.

class DakkhoAnimations {
  DakkhoAnimations._();

  // ─── Durations ───
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);

  // ─── Curves ───
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.fastOutSlowIn;  // Closest to spring in Material
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;

  // ─── Press Feedback (Layer 1) ───
  static const double pressScale = 0.96;
  static const double pressOpacity = 0.85;

  // ─── Entrance (Layer 3) ───
  static const Duration staggerInterval = Duration(milliseconds: 50);
  static const int maxStaggerItems = 8;

  // ─── Haptic Feedback ───
  static void hapticLight() => HapticFeedback.lightImpact();
  static void hapticMedium() => HapticFeedback.mediumImpact();
  static void hapticHeavy() => HapticFeedback.heavyImpact();
  static void hapticSelection() => HapticFeedback.selectionClick();
}

/// Specific named animations for high-traffic widgets
class DakkhoMicroAnimations {
  DakkhoMicroAnimations._();

  /// Loading button: spinner replaces text, button shrinks to circle
  static Widget loadingButton({
    required bool isLoading,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: DakkhoAnimations.fast,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              key: ValueKey('loader'),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
    );
  }

  /// Pulsing red dot for "LIVE" indicator
  static Widget liveDot({double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.4, 1.4),
          duration: const Duration(milliseconds: 800),
        )
        .fade(begin: 1, end: 0.5, duration: const Duration(milliseconds: 800));
  }

  /// Animated counter (for XP, course count, etc.)
  static Widget animatedCounter({
    required int value,
    Duration duration = const Duration(milliseconds: 600),
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          val.toString(),
          style: style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        );
      },
    );
  }

  /// Skeleton shimmer loader (gradient sweep)
  static Widget shimmer({
    required Widget child,
    Color baseColor = const Color(0xFF1E293B),
    Color highlightColor = const Color(0xFF334155),
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}
