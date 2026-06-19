import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class DownloadSettingsPage extends StatelessWidget {
  const DownloadSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Downloads')),
      body: const EmptyState(
        icon: LucideIcons.download,
        title: 'Downloads',
        subtitle: 'Storage limit + auto-delete + Wi-Fi only.',
      ),
    );
  }
}
