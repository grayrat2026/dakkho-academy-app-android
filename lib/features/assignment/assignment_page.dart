import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class AssignmentPage extends StatelessWidget {
  const AssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Assignments')),
      body: const EmptyState(
        icon: LucideIcons.clipboardCheck,
        title: 'Assignments',
        subtitle: 'Course assignments with due dates.',
      ),
    );
  }
}
