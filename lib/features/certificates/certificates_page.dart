import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Certificates')),
      body: const EmptyState(
        icon: LucideIcons.award,
        title: 'Certificates',
        subtitle: 'Earned certificates. Real API in Phase 3.',
      ),
    );
  }
}
