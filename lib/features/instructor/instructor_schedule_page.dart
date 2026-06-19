import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorSchedulePage extends StatelessWidget {
  const InstructorSchedulePage({super.key, required this.instructorId});
  final String instructorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('InstructorSchedule')),
      body: EmptyState(
        icon: LucideIcons.user,
        title: 'InstructorSchedule',
        subtitle: 'Instructor-specific content. Instructor ID: $instructorId',
      ),
    );
  }
}
