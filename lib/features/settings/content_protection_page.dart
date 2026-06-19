import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class ContentProtectionPage extends StatelessWidget {
  const ContentProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Content Protection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.shield, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Anti-Piracy Protection',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'DAKKHO Academy enforces strict content protection to safeguard instructor intellectual property.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          // Active protections
          _section('ACTIVE PROTECTIONS'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _protectionItem(
                  LucideIcons.lock,
                  'FLAG_SECURE',
                  'Blocks screenshots and screen recording on Android',
                  true,
                ),
                const Divider(height: 1, indent: 56),
                _protectionItem(
                  LucideIcons.keyRound,
                  'AES-256-GCM Encryption',
                  'Downloaded videos are encrypted with device-bound keys',
                  true,
                ),
                const Divider(height: 1, indent: 56),
                _protectionItem(
                  LucideIcons.smartphone,
                  'Single-Device Login',
                  'Only one device can be logged in at a time',
                  true,
                ),
                const Divider(height: 1, indent: 56),
                _protectionItem(
                  LucideIcons.radio,
                  'Concurrent Stream Kill',
                  'Only one video can stream at a time per account',
                  true,
                ),
                const Divider(height: 1, indent: 56),
                _protectionItem(
                  LucideIcons.clock,
                  '5-Minute HLS Tokens',
                  'Stream tokens expire every 5 minutes',
                  true,
                ),
                const Divider(height: 1, indent: 56),
                _protectionItem(
                  LucideIcons.calendarClock,
                  '7-Day Device Switch Cooldown',
                  'Prevents rapid device switching abuse',
                  true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Note card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, color: DakkhoColors.primary, size: 18),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'These protections are mandatory and enforced by the platform. They cannot be disabled by users.',
                    style: TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DakkhoColors.textMuted, letterSpacing: 1.5)),
  );

  Widget _protectionItem(IconData icon, String title, String subtitle, bool enabled) {
    return ListTile(
      leading: Icon(icon, color: DakkhoColors.primary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: DakkhoColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.check, size: 10, color: DakkhoColors.success),
            const SizedBox(width: 4),
            Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: DakkhoColors.success)),
          ],
        ),
      ),
    );
  }
}
