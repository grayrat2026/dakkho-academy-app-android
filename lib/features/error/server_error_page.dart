import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ServerErrorPage extends StatelessWidget {
  const ServerErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Server Error')),
      body: const EmptyState(
        icon: LucideIcons.serverCrash,
        title: 'Server Error',
        subtitle: '500 — try again later.',
      ),
    );
  }
}
