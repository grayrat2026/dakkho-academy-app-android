import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dakkho_theme.dart';
import 'gradient_button.dart';

/// EmptyState — shown when a list has no items.
///
/// Uses a floating animation on the illustration for a friendly feel.
/// Matches the web app's EmptyState component (used in MyCourses, Bookmarks, etc.).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating illustration
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: DakkhoColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: DakkhoColors.primary,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -8,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: ['NotoSansBengali'],
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DakkhoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontFamilyFallback: ['NotoSansBengali'],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: DakkhoColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
