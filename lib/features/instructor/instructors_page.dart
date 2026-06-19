import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_skeleton.dart';

class InstructorsPage extends ConsumerStatefulWidget {
  const InstructorsPage({super.key});
  @override
  ConsumerState<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends ConsumerState<InstructorsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final future = ref.watch(instructorApiProvider).maybeWhen(
      data: (api) => api.list(search: _search.isEmpty ? null : _search, limit: 50).then((r) => r.instructors),
      orElse: () => Future.value(<InstructorModel>[]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Instructors'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search instructors...',
                prefixIcon: Icon(LucideIcons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<InstructorModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(itemCount: 5, itemBuilder: (_, __) => const ListItemSkeleton());
          }
          final instructors = snapshot.data ?? [];
          if (instructors.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.users,
              title: 'No instructors found',
              subtitle: 'Try a different search.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: instructors.length,
            itemBuilder: (_, i) {
              final inst = instructors[i];
              return GlassCard(
                onTap: () => context.go('/app/instructor/${inst.id}'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: inst.avatarUrl.isNotEmpty ? NetworkImage(inst.avatarUrl) : null,
                      backgroundColor: DakkhoColors.primary,
                      child: inst.avatarUrl.isEmpty
                          ? Text(inst.name.isNotEmpty ? inst.name[0] : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(inst.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(inst.specialization,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Stat(value: inst.totalCourses, label: 'Courses'),
                        _Stat(value: inst.totalStudents, label: 'Students'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
        Text(label, style: const TextStyle(fontSize: 10, color: DakkhoColors.textSecondary)),
      ],
    );
  }
}
