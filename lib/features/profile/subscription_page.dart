import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Subscription')),
      body: const EmptyState(
        icon: LucideIcons.creditCard,
        title: 'Subscription',
        subtitle: 'Active packages + purchase flow.',
      ),
    );
  }
}
