import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExamSchedulePage extends StatelessWidget {
  const ExamSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Exam Schedule')),
      body: const EmptyState(
        icon: LucideIcons.calendarDays,
        title: 'Exam Schedule',
        subtitle: 'Exam timetable.',
      ),
    );
  }
}
