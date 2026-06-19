import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExamPracticePage extends StatelessWidget {
  const ExamPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Practice')),
      body: const EmptyState(
        icon: LucideIcons.pencil,
        title: 'Exam Practice',
        subtitle: 'Practice quiz runner.',
      ),
    );
  }
}
