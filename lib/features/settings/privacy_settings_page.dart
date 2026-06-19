import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});
  @override
  ConsumerState<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool _profileVisible = true;
  bool _discoverable = true;
  bool _analyticsOptOut = false;
  bool _showProgress = true;
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final api = await ref.read(settingsApiProvider.future);
      await api.updateSettings({
        'privacy': {
          'profileVisible': _profileVisible,
          'discoverable': _discoverable,
          'analyticsOptOut': _analyticsOptOut,
          'showProgress': _showProgress,
        },
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy settings saved!'), backgroundColor: DakkhoColors.success),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save'), backgroundColor: DakkhoColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('VISIBILITY'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.user, 'Public Profile', 'Allow others to view your profile',
                    _profileVisible, (v) => setState(() => _profileVisible = v)),
                const Divider(height: 1, indent: 56),
                _toggle(LucideIcons.search, 'Searchable', 'Others can find you by email',
                    _discoverable, (v) => setState(() => _discoverable = v)),
                const Divider(height: 1, indent: 56),
                _toggle(LucideIcons.barChart3, 'Show Learning Progress', 'Display your progress on leaderboard',
                    _showProgress, (v) => setState(() => _showProgress = v)),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('DATA & ANALYTICS'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.pieChart, 'Opt out of Analytics', 'We won\'t track your usage for analytics',
                    _analyticsOptOut, (v) => setState(() => _analyticsOptOut = v)),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('DATA REQUESTS'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(LucideIcons.download, color: DakkhoColors.primary, size: 20),
                  title: const Text('Download My Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  subtitle: const Text('Get a copy of your data (GDPR)', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  trailing: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request submitted. You will receive an email within 7 days.')),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: DakkhoColors.danger, size: 20),
                  title: const Text('Delete My Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  subtitle: const Text('Request permanent deletion', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  trailing: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                  onTap: () => Navigator.pushNamed(context, '/app/profile/delete-account'),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.check),
              label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DakkhoColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DakkhoColors.textMuted, letterSpacing: 1.5)),
  );

  Widget _toggle(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: DakkhoColors.primary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      trailing: Switch(value: value, activeColor: DakkhoColors.primary, onChanged: onChanged),
    );
  }
}
