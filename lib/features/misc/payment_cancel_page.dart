import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// PaymentCancelPage — static "payment cancelled" screen with retry/back-to-home CTAs.
class PaymentCancelPage extends StatelessWidget {
  const PaymentCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DakkhoColors.bgDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: DakkhoColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.ban, color: DakkhoColors.warning, size: 48),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: DakkhoAnimations.slow,
                  curve: DakkhoAnimations.elastic,
                ),
                const SizedBox(height: 24),
                const Text('Payment Cancelled',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DakkhoColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'Your payment was cancelled and no money was deducted. You can try again whenever you\'re ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.info, color: DakkhoColors.primary, size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Tip: Make sure you complete the payment within 15 minutes of starting checkout.',
                                style: TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Try Again',
                  icon: LucideIcons.rotateCw,
                  onPressed: () => context.go('/app/explore'),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => context.go('/app/home'),
                  icon: const Icon(LucideIcons.home, size: 14),
                  label: const Text('Back to Home'),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
