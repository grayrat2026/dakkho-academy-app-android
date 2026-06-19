import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorCoursesPage extends StatelessWidget {
  const InstructorCoursesPage({super.key, required this.instructorId});
  final String instructorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('InstructorCourses')),
      body: EmptyState(
        icon: LucideIcons.user,
        title: 'InstructorCourses',
        subtitle: 'Instructor-specific content. Instructor ID: $instructorId',
      ),
    );
  }
}
