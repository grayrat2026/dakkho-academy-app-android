import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class InstructorSchedulePage extends ConsumerStatefulWidget {
  const InstructorSchedulePage({super.key, required this.instructorId});
  final String instructorId;

  @override
  ConsumerState<InstructorSchedulePage> createState() => _InstructorSchedulePageState();
}

class _InstructorSchedulePageState extends ConsumerState<InstructorSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Schedule')),
      body: FutureBuilder<List<LiveClass>>(
        future: ref.read(liveClassApiProvider).maybeWhen(
          data: (api) => api.list().then((list) => list.where((l) => l.instructorId == widget.instructorId).toList()),
          orElse: () => Future.value(<LiveClass>[]),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.calendar,
              title: 'No upcoming sessions',
              subtitle: 'This instructor has no scheduled live classes or office hours.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              final isLive = s.status == 'live';
              final scheduledDate = DateTime.tryParse(s.scheduledAt);

              return GlassCard(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                gradient: isLive ? DakkhoColors.dangerGradient : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isLive)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.4, 1.4),
                            duration: const Duration(milliseconds: 600),
                          )
                        else
                          Icon(LucideIcons.calendar, size: 16, color: isLive ? Colors.white : DakkhoColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          isLive ? 'LIVE NOW' : 'Scheduled',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isLive ? Colors.white : DakkhoColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        if (scheduledDate != null)
                          Text(_formatDate(scheduledDate),
                              style: TextStyle(fontSize: 11, color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(s.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isLive ? Colors.white : DakkhoColors.textPrimary,
                        )),
                    if (s.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(s.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 14,
                            color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${s.durationMinutes} minutes',
                            style: TextStyle(fontSize: 12, color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                        const Spacer(),
                        if (s.meetingUrl != null && s.meetingUrl!.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => launchUrl(Uri.parse(s.meetingUrl!)),
                            icon: Icon(isLive ? LucideIcons.radio : LucideIcons.bell, size: 14),
                            label: Text(isLive ? 'Join Now' : 'Set Reminder'),
                          ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideY(begin: 0.05, end: 0);
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays > 0 && diff.inDays < 7) return '${diff.inDays} days away';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
