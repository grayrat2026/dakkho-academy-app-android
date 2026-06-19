import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/empty_state.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});
  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Just refresh user packages via the API — they're shown via user.packages
    try {
      final api = await ref.read(packageApiProvider.future);
      await api.mine();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('My Subscription')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (user != null && user.packages.isNotEmpty) ...[
                    // Active packages
                    ...user.packages.where((p) => p.status == 'active').map((p) {
                      final isActive = p.status == 'active';
                      final expiresAt = p.expiresAt != null ? DateTime.tryParse(p.expiresAt!) : null;
                      final daysLeft = expiresAt?.difference(DateTime.now()).inDays;

                      return GlassCard(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 12),
                        gradient: isActive ? DakkhoColors.primaryGradient : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white.withValues(alpha: 0.2) : DakkhoColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.packageType.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w800,
                                      color: isActive ? Colors.white : DakkhoColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (daysLeft != null)
                                  Text(
                                    '$daysLeft days left',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive ? Colors.white.withValues(alpha: 0.9) : DakkhoColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '৳${p.price} · ${p.durationMonths}mo',
                              style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900,
                                color: isActive ? Colors.white : DakkhoColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Activated: ${_formatDate(p.activatedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary,
                              ),
                            ),
                            if (p.expiresAt != null)
                              Text(
                                'Expires: ${_formatDate(p.expiresAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isActive ? Colors.white.withValues(alpha: 0.85) : DakkhoColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
                    }),

                    const SizedBox(height: 16),

                    // Buy more / extend
                    GradientButton(
                      label: 'Browse Courses',
                      icon: LucideIcons.compass,
                      onPressed: () => context.go('/app/explore'),
                    ),
                  ] else ...[
                    // No active subscription
                    const EmptyState(
                      icon: LucideIcons.creditCard,
                      title: 'No active subscription',
                      subtitle: 'Browse courses and enroll to access premium content.',
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Explore Courses',
                      icon: LucideIcons.compass,
                      onPressed: () => context.go('/app/explore'),
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  ],
                ],
              ),
            ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
