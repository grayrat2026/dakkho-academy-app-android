import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Terms')),
      body: const EmptyState(
        icon: LucideIcons.fileText,
        title: 'Terms',
        subtitle: 'Condensed terms summary.',
      ),
    );
  }
}
