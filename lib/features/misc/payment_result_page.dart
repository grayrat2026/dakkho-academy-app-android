import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Payment Result')),
      body: const EmptyState(
        icon: LucideIcons.checkCircle,
        title: 'Payment Result',
        subtitle: 'Post-payment verification.',
      ),
    );
  }
}
