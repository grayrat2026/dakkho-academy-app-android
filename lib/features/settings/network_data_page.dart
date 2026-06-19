import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class NetworkDataPage extends StatelessWidget {
  const NetworkDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Network & Data')),
      body: const EmptyState(
        icon: LucideIcons.wifi,
        title: 'Network & Data',
        subtitle: 'Data-saver toggles + Wi-Fi-only settings.',
      ),
    );
  }
}
