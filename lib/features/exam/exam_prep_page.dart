import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExamPrepPage extends StatelessWidget {
  const ExamPrepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Prep')),
      body: const EmptyState(
        icon: LucideIcons.graduationCap,
        title: 'Exam Prep',
        subtitle: 'Exam prep dashboard.',
      ),
    );
  }
}
