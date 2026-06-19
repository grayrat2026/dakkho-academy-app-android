import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExamTipsPage extends StatelessWidget {
  const ExamTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Tips')),
      body: const EmptyState(
        icon: LucideIcons.lightbulb,
        title: 'Exam Tips',
        subtitle: 'Study + exam strategies.',
      ),
    );
  }
}
