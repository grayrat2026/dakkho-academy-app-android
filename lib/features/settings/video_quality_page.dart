import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class VideoQualityPage extends StatelessWidget {
  const VideoQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Video Quality')),
      body: const EmptyState(
        icon: LucideIcons.monitor,
        title: 'Video Quality',
        subtitle: 'Streaming + download quality selectors.',
      ),
    );
  }
}
