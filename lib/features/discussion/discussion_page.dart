import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class DiscussionPage extends StatelessWidget {
  const DiscussionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Discussion')),
      body: const EmptyState(
        icon: LucideIcons.messagesSquare,
        title: 'Discussion',
        subtitle: 'General discussion forum.',
      ),
    );
  }
}
