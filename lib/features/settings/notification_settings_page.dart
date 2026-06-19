import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Notifications')),
      body: const EmptyState(
        icon: LucideIcons.bell,
        title: 'Notifications',
        subtitle: 'Per-channel notification toggles.',
      ),
    );
  }
}
