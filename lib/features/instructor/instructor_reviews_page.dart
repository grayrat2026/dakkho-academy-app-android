import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorReviewsPage extends StatelessWidget {
  const InstructorReviewsPage({super.key, required this.instructorId});
  final String instructorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('InstructorReviews')),
      body: EmptyState(
        icon: LucideIcons.user,
        title: 'InstructorReviews',
        subtitle: 'Instructor-specific content. Instructor ID: $instructorId',
      ),
    );
  }
}
