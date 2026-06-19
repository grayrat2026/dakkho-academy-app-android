import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Account')),
      body: const EmptyState(
        icon: LucideIcons.user,
        title: 'Account',
        subtitle: 'Account info + 2FA + email verification.',
      ),
    );
  }
}
