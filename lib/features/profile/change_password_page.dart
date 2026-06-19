import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Change Password')),
      body: const EmptyState(
        icon: LucideIcons.keyRound,
        title: 'Change Password',
        subtitle: 'Change password form with strength meter.',
      ),
    );
  }
}
