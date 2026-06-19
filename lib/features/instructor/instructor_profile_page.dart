import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorProfilePage extends StatelessWidget {
  const InstructorProfilePage({super.key, required this.instructorId});
  final String instructorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Instructor')),
      body: EmptyState(
        icon: LucideIcons.user,
        title: 'Instructor Profile',
        subtitle: 'Instructor bio + course grid. ID: $instructorId',
      ),
    );
  }
}
