import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Help')),
      body: const EmptyState(
        icon: LucideIcons.helpCircle,
        title: 'Help',
        subtitle: 'Help hub.',
      ),
    );
  }
}
