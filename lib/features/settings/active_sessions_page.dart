import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ActiveSessionsPage extends StatelessWidget {
  const ActiveSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Active Sessions')),
      body: const EmptyState(
        icon: LucideIcons.smartphone,
        title: 'Active Sessions',
        subtitle: 'List of login sessions + revoke.',
      ),
    );
  }
}
