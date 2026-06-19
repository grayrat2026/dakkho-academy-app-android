import 'package:flutter/material.dart';
import '../../shared/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyState(
        icon: LucideIcons.settings,
        title: 'Settings',
        subtitle: '13 sub-pages (account, theme, downloads, video quality, 2FA, etc.) arrive in Phase 8.',
      ),
    );
  }
}
