import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ReportIssuePage extends StatelessWidget {
  const ReportIssuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Report Issue')),
      body: const EmptyState(
        icon: LucideIcons.bug,
        title: 'Report Issue',
        subtitle: 'Bug report form.',
      ),
    );
  }
}
