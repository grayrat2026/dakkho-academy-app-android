import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PaymentCancelPage extends StatelessWidget {
  const PaymentCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Payment Cancelled')),
      body: const EmptyState(
        icon: LucideIcons.xCircle,
        title: 'Payment Cancelled',
        subtitle: 'Payment cancelled with retry.',
      ),
    );
  }
}
