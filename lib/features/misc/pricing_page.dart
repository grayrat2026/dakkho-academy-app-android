import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Pricing')),
      body: const EmptyState(
        icon: LucideIcons.tag,
        title: 'Pricing',
        subtitle: 'Free / Pro / Premium plan comparison.',
      ),
    );
  }
}
