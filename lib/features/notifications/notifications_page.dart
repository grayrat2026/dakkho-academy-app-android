import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/models/models.dart';
import '../../data/stores/stores.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchFromServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.any((n) => !n.read))
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.bell,
                  title: 'No notifications',
                  subtitle: 'You\'ll see updates about new courses, live sessions, and announcements here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  itemBuilder: (_, i) {
                    final n = state.notifications[i];
                    return _NotificationCard(
                      notification: n,
                      onTap: () {
                        if (!n.read) ref.read(notificationProvider.notifier).markAsRead(n.id);
                        if (n.actionUrl != null) context.go(n.actionUrl!);
                      },
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
                  },
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  Color _typeColor() {
    return switch (notification.type) {
      'success' || 'achievement' => DakkhoColors.success,
      'warning' => DakkhoColors.warning,
      'error' || 'urgent' => DakkhoColors.danger,
      'announcement' => DakkhoColors.purple,
      _ => DakkhoColors.primary,
    };
  }

  IconData _typeIcon() {
    return switch (notification.type) {
      'success' || 'achievement' => LucideIcons.checkCircle,
      'warning' => LucideIcons.alertTriangle,
      'error' || 'urgent' => LucideIcons.alertCircle,
      'announcement' => LucideIcons.megaphone,
      _ => LucideIcons.bell,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
                            color: DakkhoColors.textPrimary,
                          )),
                    ),
                    if (!notification.read)
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: DakkhoColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.message,
                    style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
