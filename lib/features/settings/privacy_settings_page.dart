import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy')),
      body: const EmptyState(
        icon: LucideIcons.shield,
        title: 'Privacy',
        subtitle: 'Privacy toggles + data requests.',
      ),
    );
  }
}
