import 'package:flutter/material.dart';
import '../../shared/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EmptyState(
        icon: LucideIcons.download,
        title: 'No Downloads',
        subtitle: 'Encrypted downloads arrive in Phase 7.\nVideos will be saved as .enc files (AES-256-GCM).',
      ),
    );
  }
}
