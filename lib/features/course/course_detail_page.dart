import 'package:flutter/material.dart';
import '../../shared/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EmptyState(
        icon: LucideIcons.bookOpen,
        title: 'Course Detail',
        subtitle: 'Course detail + curriculum + checkout (Phase 4).\nCourse ID: $courseId',
      ),
    );
  }
}
