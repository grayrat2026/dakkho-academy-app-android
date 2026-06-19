import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const EmptyState(
        icon: LucideIcons.fileText,
        title: 'Terms of Service',
        subtitle: 'Full Terms of Service.',
      ),
    );
  }
}
