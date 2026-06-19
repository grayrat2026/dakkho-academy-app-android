import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class CourseQuizzesPage extends StatelessWidget {
  const CourseQuizzesPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('CourseQuizzes')),
      body: EmptyState(
        icon: LucideIcons.bookOpen,
        title: 'CourseQuizzes',
        subtitle: 'Course-specific content. Course ID: $courseId',
      ),
    );
  }
}
