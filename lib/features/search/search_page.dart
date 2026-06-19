import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/empty_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EmptyState(
        icon: LucideIcons.search,
        title: 'Search',
        subtitle: 'Real API search + recent searches arrive in Phase 3.',
      ),
    );
  }
}
