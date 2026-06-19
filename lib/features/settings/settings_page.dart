import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _sections = [
    {
      'title': 'Account',
      'items': [
        (LucideIcons.user, 'Account', '/app/settings/account'),
        (LucideIcons.bell, 'Notifications', '/app/settings/notifications'),
        (LucideIcons.shield, 'Privacy', '/app/settings/privacy'),
        (LucideIcons.keyRound, '2FA', '/app/2fa-setup'),
      ],
    },
    {
      'title': 'Appearance',
      'items': [
        (LucideIcons.palette, 'Theme', '/app/settings/theme'),
        (LucideIcons.languages, 'Language', '/app/settings/language'),
      ],
    },
    {
      'title': 'Playback',
      'items': [
        (LucideIcons.monitor, 'Video Quality', '/app/settings/video-quality'),
        (LucideIcons.download, 'Downloads', '/app/settings/downloads'),
        (LucideIcons.wifi, 'Network & Data', '/app/settings/network-data'),
        (LucideIcons.lock, 'Content Protection', '/app/settings/content-protection'),
      ],
    },
    {
      'title': 'Sessions',
      'items': [
        (LucideIcons.smartphone, 'Active Sessions', '/app/settings/sessions'),
        (LucideIcons.smartphone, 'Device Binding', '/app/device'),
      ],
    },
    {
      'title': 'Help',
      'items': [
        (LucideIcons.helpCircle, 'Help Center', '/app/help'),
        (LucideIcons.fileText, 'Terms of Service', '/app/help/terms-of-service'),
        (LucideIcons.shieldCheck, 'Privacy Policy', '/app/help/privacy-policy'),
        (LucideIcons.info, 'About DAKKHO', '/app/about'),
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        itemBuilder: (_, sectionIdx) {
          final section = _sections[sectionIdx];
          final items = section['items'] as List;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(section['title'] as String,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: DakkhoColors.textMuted, letterSpacing: 1.5,
                    )),
              ),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      ListTile(
                        leading: Icon(items[i].$1 as IconData, color: DakkhoColors.primary, size: 20),
                        title: Text(items[i].$2 as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DakkhoColors.textPrimary)),
                        trailing: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                        onTap: () => context.go(items[i].$3 as String),
                      ),
                      if (i < items.length - 1) const Divider(height: 1, indent: 56),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 80 * sectionIdx)).slideX(begin: 0.05, end: 0),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
