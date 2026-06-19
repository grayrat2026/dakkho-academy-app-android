import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

/// PrivacyPage — condensed Privacy summary with key-point cards.
/// Links to full Privacy Policy for details.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const _keyPoints = [
    {
      'icon': LucideIcons.database,
      'title': 'What We Collect',
      'summary': 'Account info (name, email), learning data (progress, bookmarks), device UUID, and usage analytics. We do NOT store card details.',
    },
    {
      'icon': LucideIcons.shield,
      'title': 'How We Protect It',
      'summary': 'All data encrypted in transit (HTTPS) and at rest (Cloudflare D1 + R2 with encryption). Auth tokens in Android Keystore.',
    },
    {
      'icon': LucideIcons.users,
      'title': 'Who We Share With',
      'summary': 'We do NOT sell your data. We share minimal data only with: PipraPay (payments), OneSignal (push), Resend (email), Cloudflare (hosting).',
    },
    {
      'icon': LucideIcons.smartphone,
      'title': 'Single-Device Login',
      'summary': 'For content protection, only one device can be logged in at a time. The previous device is auto-logged-out when you log in elsewhere.',
    },
    {
      'icon': LucideIcons.userX,
      'title': 'Your Right to Delete',
      'summary': 'You can delete your account anytime from Settings → Account → Delete Account. All your data is permanently removed within 30 days.',
    },
    {
      'icon': LucideIcons.download,
      'title': 'Data Portability',
      'summary': 'You can request a copy of your data in JSON format. Contact privacy@dakkho.pro.bd to make a request.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: LinearGradient(colors: [DakkhoColors.accent, DakkhoColors.primary]),
            child: Column(
              children: [
                const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
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
                    color: DakkhoColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(p['icon'] as IconData, color: DakkhoColors.accent, size: 18),
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

          // Full policy link
          GlassCard(
            onTap: () => context.go('/app/help/privacy-policy'),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(LucideIcons.arrowRightCircle, color: DakkhoColors.accent, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Read Full Privacy Policy',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.accent)),
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
