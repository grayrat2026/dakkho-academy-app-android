import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExamResultsPage extends StatelessWidget {
  const ExamResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Results')),
      body: const EmptyState(
        icon: LucideIcons.fileBarChart,
        title: 'Exam Results',
        subtitle: 'Per-semester GPA + grades.',
      ),
    );
  }
}
