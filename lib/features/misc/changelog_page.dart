import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Changelog')),
      body: const EmptyState(
        icon: LucideIcons.history,
        title: 'Changelog',
        subtitle: 'Versioned release notes.',
      ),
    );
  }
}
