import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EmptyState(
        icon: LucideIcons.compass,
        title: 'Explore Courses',
        subtitle: 'Real course catalog + filters arrive in Phase 3.',
      ),
    );
  }
}
