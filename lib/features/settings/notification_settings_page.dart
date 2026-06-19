import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../shared/widgets/glass_card.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});
  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  // Per-channel toggles (local state, persisted via /api/settings)
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _inAppEnabled = true;
  final Map<String, bool> _categories = {
    'new_course': true,
    'live_session': true,
    'announcement': true,
    'assignment': true,
    'achievement': true,
    'discussion': false,
    'marketing': false,
  };
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final api = await ref.read(settingsApiProvider.future);
      await api.updateSettings({
        'notifications': {
          'push': _pushEnabled,
          'email': _emailEnabled,
          'inApp': _inAppEnabled,
          'categories': _categories,
        },
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!'), backgroundColor: DakkhoColors.success),
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
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('CHANNELS'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggleItem(LucideIcons.bell, 'Push Notifications', 'Receive notifications on this device',
                    _pushEnabled, (v) => setState(() => _pushEnabled = v)),
                const Divider(height: 1, indent: 56),
                _toggleItem(LucideIcons.mail, 'Email', 'Get updates via email',
                    _emailEnabled, (v) => setState(() => _emailEnabled = v)),
                const Divider(height: 1, indent: 56),
                _toggleItem(LucideIcons.smartphone, 'In-App', 'Show notifications inside the app',
                    _inAppEnabled, (v) => setState(() => _inAppEnabled = v)),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _sectionHeader('CATEGORIES'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: _categories.entries.map((entry) {
                final items = <Widget>[];
                if (items.isNotEmpty) items.add(const Divider(height: 1, indent: 56));
                items.add(_toggleItem(
                  _categoryIcon(entry.key),
                  _categoryLabel(entry.key),
                  _categoryDescription(entry.key),
                  entry.value,
                  (v) => setState(() => _categories[entry.key] = v),
                ));
                return Column(children: items);
              }).toList(),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Save button
          // Note: replaces default unstyled button to match our glassmorphism aesthetic
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.check),
              label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DakkhoColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DakkhoColors.textMuted, letterSpacing: 1.5)),
    );
  }

  Widget _toggleItem(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: DakkhoColors.primary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      trailing: Switch(value: value, activeColor: DakkhoColors.primary, onChanged: onChanged),
    );
  }

  IconData _categoryIcon(String key) => switch (key) {
    'new_course' => LucideIcons.bookOpen,
    'live_session' => LucideIcons.radio,
    'announcement' => LucideIcons.megaphone,
    'assignment' => LucideIcons.clipboardCheck,
    'achievement' => LucideIcons.trophy,
    'discussion' => LucideIcons.messagesSquare,
    'marketing' => LucideIcons.tag,
    _ => LucideIcons.bell,
  };

  String _categoryLabel(String key) => switch (key) {
    'new_course' => 'New Courses',
    'live_session' => 'Live Sessions',
    'announcement' => 'Announcements',
    'assignment' => 'Assignments',
    'achievement' => 'Achievements',
    'discussion' => 'Discussion Replies',
    'marketing' => 'Promotions',
    _ => key,
  };

  String _categoryDescription(String key) => switch (key) {
    'new_course' => 'When new courses are published',
    'live_session' => 'When live classes start',
    'announcement' => 'Course and platform announcements',
    'assignment' => 'Assignment due dates and grades',
    'achievement' => 'When you earn achievements',
    'discussion' => 'Replies to your Q&A posts',
    'marketing' => 'Special offers and discounts',
    _ => '',
  };
}
