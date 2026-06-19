import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Maintenance')),
      body: const EmptyState(
        icon: LucideIcons.wrench,
        title: 'Maintenance',
        subtitle: 'Maintenance mode with countdown.',
      ),
    );
  }
}
