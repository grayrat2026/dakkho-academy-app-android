import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

/// TermsPage — condensed Terms summary with key-point cards.
/// Links to full Terms of Service for the legalese.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const _keyPoints = [
    {
      'icon': LucideIcons.userCheck,
      'title': 'Eligibility',
      'summary': 'You must be 16+ to use DAKKHO Academy. By using the service, you confirm you meet this requirement.',
    },
    {
      'icon': LucideIcons.lock,
      'title': 'Single-Device Login',
      'summary': 'Only ONE device can be logged in at a time. Sharing accounts is prohibited and will result in account termination.',
    },
    {
      'icon': LucideIcons.shield,
      'title': 'Content Protection',
      'summary': 'Screenshots, recording, and content redistribution are strictly prohibited. Violations lead to immediate account ban.',
    },
    {
      'icon': LucideIcons.creditCard,
      'title': 'Payments',
      'summary': 'All payments are processed via PipraPay. Refunds available within 7 days if you\'ve watched less than 25% of the course.',
    },
    {
      'icon': LucideIcons.copyright,
      'title': 'Content Ownership',
      'summary': 'All course content is the intellectual property of DAKKHO Academy and our instructors. You may not redistribute it.',
    },
    {
      'icon': LucideIcons.ban,
      'title': 'Account Termination',
      'summary': 'We can suspend or terminate your account for Terms violations. You can delete your account anytime from Settings.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Terms Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              children: [
                const Icon(LucideIcons.fileText, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                const Text('Terms of Service', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Quick summary of key points',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          // Key points
          ..._keyPoints.map((p) => GlassCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DakkhoColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(p['icon'] as IconData, color: DakkhoColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['title'] as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(p['summary'] as String,
                          style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0)),

          const SizedBox(height: 16),

          // Full terms link
          GlassCard(
            onTap: () => context.go('/app/help/terms-of-service'),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(LucideIcons.arrowRightCircle, color: DakkhoColors.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Read Full Terms of Service',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                ),
                Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}
