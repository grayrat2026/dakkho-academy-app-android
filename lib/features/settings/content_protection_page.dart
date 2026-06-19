import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ContentProtectionPage extends StatelessWidget {
  const ContentProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Content Protection')),
      body: const EmptyState(
        icon: LucideIcons.lock,
        title: 'Content Protection',
        subtitle: 'Read-only info — admin-controlled.',
      ),
    );
  }
}
