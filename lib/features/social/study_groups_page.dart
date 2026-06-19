import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class StudyGroupsPage extends StatelessWidget {
  const StudyGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Study Groups')),
      body: const EmptyState(
        icon: LucideIcons.users,
        title: 'Study Groups',
        subtitle: 'Browseable + joinable study groups.',
      ),
    );
  }
}
