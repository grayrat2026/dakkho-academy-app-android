import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../data/stores/auth_store.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: DakkhoColors.primary,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!) as ImageProvider
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            (user?.name ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Student',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary),
                  ),
                  if (user?.technologyName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: DakkhoColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user!.technologyName!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DakkhoColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings button
            GlassCard(
              onTap: () => context.go('/app/settings'),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(LucideIcons.settings, color: DakkhoColors.primary, size: 22),
                  SizedBox(width: 16),
                  Expanded(child: Text('Settings', style: TextStyle(fontWeight: FontWeight.w600))),
                  Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Device Binding
            GlassCard(
              onTap: () => context.go('/app/device'),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(LucideIcons.smartphone, color: DakkhoColors.primary, size: 22),
                  SizedBox(width: 16),
                  Expanded(child: Text('Device Binding', style: TextStyle(fontWeight: FontWeight.w600))),
                  Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout
            GradientButton(
              label: 'Logout',
              icon: LucideIcons.logOut,
              gradient: DakkhoColors.dangerGradient,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
