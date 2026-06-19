import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

/// ChangelogPage — versioned release notes with highlights and feature/bugfix lists.
class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  static const _releases = [
    {
      'version': '1.0.0',
      'date': 'June 19, 2026',
      'isCurrent': true,
      'highlights': [
        'Brand new Flutter Android app with native feel',
        'Single-device login with force-logout',
        'AES-256-GCM encrypted downloads',
        'Universal video player (HLS + YouTube + MP4)',
      ],
      'features': [
        'Glassmorphism dark theme with Light/Dark/System modes',
        '97 routes ported from web app',
        'Real API integration for 22+ pages',
        'Anti-piracy: FLAG_SECURE, stream kill, 5-min tokens',
        'Subject > Class > Unit > Lesson curriculum hierarchy',
        'MCQ quiz runner with explanations',
        'PipraPay checkout with coupon validation',
        'Bengali + English localization',
        'OneSignal push notifications (no Firebase)',
      ],
      'bugfixes': [
        'Fixed: bookmark not persisting across sessions',
        'Fixed: video progress not syncing to backend',
        'Fixed: payment status not refreshing after enrollment',
      ],
    },
    {
      'version': '0.9.0',
      'date': 'June 10, 2026',
      'isCurrent': false,
      'highlights': [
        'Beta release with core features',
      ],
      'features': [
        'Login + signup + OTP verification',
        'Course browsing + enrollment',
        'HLS video streaming',
        'Basic progress tracking',
      ],
      'bugfixes': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Changelog')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _releases.length,
        itemBuilder: (_, i) {
          final r = _releases[i];
          return GlassCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (r['isCurrent'] == true ? DakkhoColors.success : DakkhoColors.primary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('v${r['version']}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                              color: r['isCurrent'] == true ? DakkhoColors.success : DakkhoColors.primary,
                              fontFamily: 'monospace')),
                    ),
                    const SizedBox(width: 8),
                    if (r['isCurrent'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: DakkhoColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: const Text('CURRENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: DakkhoColors.success)),
                      ),
                    const Spacer(),
                    Text(r['date'] as String, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  ],
                ),

                // Highlights
                if ((r['highlights'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(LucideIcons.sparkles, size: 14, color: DakkhoColors.warning),
                    const SizedBox(width: 6),
                    const Text('Highlights', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  ...((r['highlights'] as List).map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.star, size: 12, color: DakkhoColors.warning),
                        const SizedBox(width: 8),
                        Expanded(child: Text(h as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textPrimary, height: 1.4))),
                      ],
                    ),
                  ))),
                ],

                // Features
                if ((r['features'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(LucideIcons.plusCircle, size: 14, color: DakkhoColors.success),
                    const SizedBox(width: 6),
                    const Text('New Features', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  ...((r['features'] as List).map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.check, size: 12, color: DakkhoColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.4))),
                      ],
                    ),
                  ))),
                ],

                // Bugfixes
                if ((r['bugfixes'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(LucideIcons.bug, size: 14, color: DakkhoColors.danger),
                    const SizedBox(width: 6),
                    const Text('Bug Fixes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  ...((r['bugfixes'] as List).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.wrench, size: 12, color: DakkhoColors.danger),
                        const SizedBox(width: 8),
                        Expanded(child: Text(b as String, style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.4))),
                      ],
                    ),
                  ))),
                ],
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }
}
