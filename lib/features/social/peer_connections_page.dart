import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class PeerConnectionsPage extends StatelessWidget {
  const PeerConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Peers')),
      body: const EmptyState(
        icon: LucideIcons.userPlus,
        title: 'Peers',
        subtitle: 'Peer suggestions + connections.',
      ),
    );
  }
}
