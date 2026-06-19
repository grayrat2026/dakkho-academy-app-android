import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Feedback')),
      body: const EmptyState(
        icon: LucideIcons.messageCircle,
        title: 'Feedback',
        subtitle: 'Feature requests + bug reports.',
      ),
    );
  }
}
