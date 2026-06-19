import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('FAQ')),
      body: const EmptyState(
        icon: LucideIcons.helpCircle,
        title: 'FAQ',
        subtitle: 'Searchable FAQ accordion.',
      ),
    );
  }
}
