import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Community')),
      body: const EmptyState(
        icon: LucideIcons.messageSquare,
        title: 'Community',
        subtitle: 'Social feed of posts.',
      ),
    );
  }
}
