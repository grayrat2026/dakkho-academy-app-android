import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class LearningStatsPage extends StatelessWidget {
  const LearningStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Learning Stats')),
      body: const EmptyState(
        icon: LucideIcons.barChart3,
        title: 'Learning Stats',
        subtitle: 'Hours watched, streak, subject progress.',
      ),
    );
  }
}
