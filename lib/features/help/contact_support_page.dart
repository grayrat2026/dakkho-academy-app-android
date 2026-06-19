import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Contact Support')),
      body: const EmptyState(
        icon: LucideIcons.lifeBuoy,
        title: 'Contact Support',
        subtitle: 'Support ticket form.',
      ),
    );
  }
}
