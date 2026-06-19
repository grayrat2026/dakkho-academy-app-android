import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EmptyState(
        icon: LucideIcons.bell,
        title: 'No Notifications',
        subtitle: 'Real FCM notifications arrive in Phase 9.',
      ),
    );
  }
}
