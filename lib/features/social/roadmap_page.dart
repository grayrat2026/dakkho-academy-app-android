import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Roadmap')),
      body: const EmptyState(
        icon: LucideIcons.map,
        title: 'Roadmap',
        subtitle: 'Product roadmap with voting.',
      ),
    );
  }
}
