import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy')),
      body: const EmptyState(
        icon: LucideIcons.shield,
        title: 'Privacy',
        subtitle: 'Condensed privacy summary.',
      ),
    );
  }
}
