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

class LiveSessionsPage extends ConsumerStatefulWidget {
  const LiveSessionsPage({super.key});
  @override
  ConsumerState<LiveSessionsPage> createState() => _LiveSessionsPageState();
}

class _LiveSessionsPageState extends ConsumerState<LiveSessionsPage> {
  @override
  Widget build(BuildContext context) {
    final future = ref.watch(liveClassApiProvider).maybeWhen(
      data: (api) => api.list(),
      orElse: () => Future.value(<LiveClass>[]),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Live Sessions')),
      body: FutureBuilder<List<LiveClass>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final live = snapshot.data ?? [];
          if (live.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.radio,
              title: 'No live sessions',
              subtitle: 'Upcoming and live classes will appear here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: live.length,
            itemBuilder: (_, i) {
              final l = live[i];
              final isLive = l.status == 'live';
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
                          Icon(LucideIcons.calendar, size: 16, color: DakkhoColors.primary),
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
                        Text('${l.durationMinutes}min',
                            style: TextStyle(fontSize: 11, color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(l.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isLive ? Colors.white : DakkhoColors.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    Text(l.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: isLive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary)),
                    const SizedBox(height: 16),
                    if (l.meetingUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(Uri.parse(l.meetingUrl!)),
                          icon: Icon(isLive ? LucideIcons.radio : LucideIcons.calendarPlus, size: 16),
                          label: Text(isLive ? 'Join Now' : 'Add to Calendar'),
                        ),
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
}
