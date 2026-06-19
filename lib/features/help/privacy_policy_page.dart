import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const EmptyState(
        icon: LucideIcons.shieldCheck,
        title: 'Privacy Policy',
        subtitle: 'Full Privacy Policy.',
      ),
    );
  }
}
