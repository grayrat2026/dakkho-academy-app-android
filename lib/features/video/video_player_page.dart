import 'package:flutter/material.dart';
import '../../shared/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VideoPlayerPage extends StatelessWidget {
  const VideoPlayerPage({super.key, required this.courseId, required this.videoId});
  final String courseId;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: EmptyState(
        icon: LucideIcons.playCircle,
        title: 'Video Player',
        subtitle: 'UnifiedVideoPlayer (HLS + YouTube + MP4) arrives in Phase 5.\nVideo ID: $videoId',
      ),
    );
  }
}
