import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Language')),
      body: const EmptyState(
        icon: LucideIcons.languages,
        title: 'Language',
        subtitle: 'App language + subtitle language.',
      ),
    );
  }
}
