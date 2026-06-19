import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/stores/auth_store.dart';
import '../../shared/widgets/glass_card.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});
  @override
  ConsumerState<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  Map<String, dynamic>? _twoFAStatus;
  bool _isLoading2FA = true;

  @override
  void initState() {
    super.initState();
    _load2FA();
  }

  Future<void> _load2FA() async {
    try {
      final api = await ref.read(twoFAApiProvider.future);
      _twoFAStatus = await api.status();
    } catch (_) {}
    setState(() => _isLoading2FA = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: DakkhoColors.primary,
                  backgroundImage: user?.avatarUrl?.isNotEmpty == true ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl?.isEmpty == true
                      ? Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                      Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary),
                  onPressed: () => context.go('/app/profile/edit'),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Section: Security
          _sectionHeader('SECURITY'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _settingItem(
                  icon: LucideIcons.keyRound,
                  title: 'Change Password',
                  subtitle: 'Last changed 30 days ago',
                  onTap: () => context.go('/app/profile/change-password'),
                ),
                const Divider(height: 1, indent: 56),
                _settingItem(
                  icon: LucideIcons.shieldCheck,
                  title: 'Two-Factor Authentication',
                  subtitle: _isLoading2FA
                      ? 'Loading...'
                      : (_twoFAStatus?['enabled'] == true ? 'Enabled' : 'Not enabled'),
                  trailing: _isLoading2FA
                      ? null
                      : Switch(
                          value: _twoFAStatus?['enabled'] == true,
                          activeColor: DakkhoColors.primary,
                          onChanged: (v) async {
                            if (v) {
                              context.go('/app/2fa-setup');
                            } else {
                              context.go('/app/2fa-disable');
                            }
                          },
                        ),
                ),
                const Divider(height: 1, indent: 56),
                _settingItem(
                  icon: LucideIcons.mail,
                  title: 'Email Verification',
                  subtitle: user?.emailVerified == true ? 'Verified' : 'Not verified',
                  trailing: user?.emailVerified == true
                      ? const Icon(LucideIcons.checkCircle, color: DakkhoColors.success, size: 20)
                      : const Icon(LucideIcons.alertCircle, color: DakkhoColors.warning, size: 20),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Section: Danger Zone
          _sectionHeader('DANGER ZONE'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _settingItem(
                  icon: LucideIcons.logOut,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  iconColor: DakkhoColors.warning,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Logout?'),
                        content: const Text('You will be signed out from this device.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _settingItem(
                  icon: LucideIcons.trash2,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  iconColor: DakkhoColors.danger,
                  onTap: () => context.go('/app/profile/delete-account'),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DakkhoColors.textMuted, letterSpacing: 1.5)),
    );
  }

  Widget _settingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = DakkhoColors.primary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      trailing: trailing ?? (onTap != null ? const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18) : null),
      onTap: onTap,
    );
  }
}
