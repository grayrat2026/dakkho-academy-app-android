import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class CourseQAPage extends StatelessWidget {
  const CourseQAPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('CourseQa')),
      body: EmptyState(
        icon: LucideIcons.bookOpen,
        title: 'CourseQa',
        subtitle: 'Course-specific content. Course ID: $courseId',
      ),
    );
  }
}
