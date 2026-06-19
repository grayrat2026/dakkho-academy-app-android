import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Course')),
      body: EmptyState(
        icon: LucideIcons.bookOpen,
        title: 'Course Detail',
        subtitle: 'Full course detail with checkout arrives in Phase 4.\nCourse ID: $courseId',
      ),
    );
  }
}
