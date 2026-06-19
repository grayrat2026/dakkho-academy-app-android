import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/empty_state.dart';

class ActiveSessionsPage extends ConsumerStatefulWidget {
  const ActiveSessionsPage({super.key});
  @override
  ConsumerState<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends ConsumerState<ActiveSessionsPage> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await ref.read(sessionApiProvider.future);
      _sessions = await api.list();
    } catch (_) {
      // Fallback: show current device as the only session (single-device login)
      final user = ref.read(authProvider).user;
      _sessions = [{
        'id': 'current',
        'device_info': 'This device (Android)',
        'ip_address': 'Current IP',
        'created_at': DateTime.now().toIso8601String(),
        'is_current': true,
        'name': user?.name ?? '',
      }];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _revokeAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke all sessions?'),
        content: const Text('You will be logged out from this device too. You\'ll need to log in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Revoke All')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final api = await ref.read(sessionApiProvider.future);
      await api.revokeAll();
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: DakkhoColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Active Sessions'),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.logOut, color: DakkhoColors.danger),
              onPressed: _revokeAll,
              tooltip: 'Revoke All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.smartphone,
                  title: 'No active sessions',
                  subtitle: 'You are not logged in on any device.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (_, i) {
                    final s = _sessions[i];
                    final isCurrent = s['is_current'] == true;
                    final createdAt = DateTime.tryParse(s['created_at'] as String? ?? '') ?? DateTime.now();

                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      gradient: isCurrent ? DakkhoColors.primaryGradient : null,
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: isCurrent ? Colors.white.withValues(alpha: 0.2) : DakkhoColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(LucideIcons.smartphone,
                                color: isCurrent ? Colors.white : DakkhoColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      s['device_info'] as String? ?? 'Unknown device',
                                      style: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w700,
                                        color: isCurrent ? Colors.white : DakkhoColors.textPrimary,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('THIS DEVICE',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'IP: ${s['ip_address'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCurrent ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  'Logged in: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isCurrent ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * i)).slideX(begin: 0.05, end: 0);
                  },
                ),
    );
  }
}
