import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Referral')),
      body: const EmptyState(
        icon: LucideIcons.gift,
        title: 'Referral',
        subtitle: 'Referral link + reward tiers + activity.',
      ),
    );
  }
}
