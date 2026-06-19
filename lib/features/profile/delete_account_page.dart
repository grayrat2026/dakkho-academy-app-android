import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Delete Account')),
      body: const EmptyState(
        icon: LucideIcons.alertTriangle,
        title: 'Delete Account',
        subtitle: 'Multi-step account deletion wizard.',
      ),
    );
  }
}
