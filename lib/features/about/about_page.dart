import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('About DAKKHO')),
      body: const EmptyState(
        icon: LucideIcons.info,
        title: 'About DAKKHO',
        subtitle: 'Mission, stats, FAQ, contact.',
      ),
    );
  }
}
