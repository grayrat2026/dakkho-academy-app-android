import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Refund Policy')),
      body: const EmptyState(
        icon: LucideIcons.rotateCcw,
        title: 'Refund Policy',
        subtitle: 'Refund eligibility + process.',
      ),
    );
  }
}
