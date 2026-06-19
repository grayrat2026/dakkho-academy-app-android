import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

/// StudyGroupsPage — browseable + joinable study groups.
/// Backend: TODO — /api/study-groups doesn't exist yet. In-memory sample data.
class StudyGroupsPage extends StatefulWidget {
  const StudyGroupsPage({super.key});
  @override
  State<StudyGroupsPage> createState() => _StudyGroupsPageState();
}

class _StudyGroupsPageState extends State<StudyGroupsPage> {
  final List<Map<String, dynamic>> _groups = [
    {'name': 'CSE Semester 5 Study Group', 'subject': 'Microprocessor', 'members': 12, 'maxMembers': 20, 'description': 'Weekly meetups to discuss microprocessor concepts and lab work.', 'isJoined': false, 'color': DakkhoColors.primary},
    {'name': 'Physics Final Prep', 'subject': 'Physics 1st Paper', 'members': 8, 'maxMembers': 15, 'description': 'Solving past papers and discussing difficult problems together.', 'isJoined': true, 'color': DakkhoColors.accent},
    {'name': 'Database Design Crew', 'subject': 'Database Management', 'members': 15, 'maxMembers': 15, 'description': 'Building real-world database projects. Currently full.', 'isJoined': false, 'color': DakkhoColors.purple},
    {'name': 'Math Wizards', 'subject': 'Mathematics-IV', 'members': 6, 'maxMembers': 10, 'description': 'Advanced problem-solving sessions for math enthusiasts.', 'isJoined': false, 'color': DakkhoColors.warning},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Study Groups'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (_, i) {
          final g = _groups[i];
          final isFull = g['members'] == g['maxMembers'];
          return GlassCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [(g['color'] as Color), (g['color'] as Color).withValues(alpha: 0.6)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.users, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                          Text(g['subject'], style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (g['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${g['members']}/${g['maxMembers']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: g['color'] as Color)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(g['description'], style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(LucideIcons.users, size: 12, color: DakkhoColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${g['members']} members', style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                    const Spacer(),
                    if (g['isJoined'])
                      OutlinedButton.icon(
                        onPressed: () => setState(() => g['isJoined'] = false),
                        icon: const Icon(LucideIcons.check, size: 14),
                        label: const Text('Joined'),
                        style: OutlinedButton.styleFrom(foregroundColor: DakkhoColors.success, side: BorderSide(color: DakkhoColors.success.withValues(alpha: 0.5))),
                      )
                    else if (isFull)
                      const Text('FULL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DakkhoColors.danger))
                    else
                      GradientButton(
                        label: 'Join',
                        icon: LucideIcons.userPlus,
                        onPressed: () => setState(() {
                          g['isJoined'] = true;
                          g['members']++;
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Study Group'),
        content: const Text('This feature is coming soon! For now, browse and join existing groups.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}
