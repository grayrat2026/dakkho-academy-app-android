import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class DownloadSettingsPage extends StatefulWidget {
  const DownloadSettingsPage({super.key});
  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  double _storageLimit = 2000;  // MB
  bool _autoDelete = true;
  bool _wifiOnly = true;
  String _downloadQuality = '720';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Downloads')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('STORAGE'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Storage Limit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                    Text('${(_storageLimit / 1000).toStringAsFixed(1)} GB', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                  ],
                ),
                Slider(
                  value: _storageLimit, min: 500, max: 10000, divisions: 19,
                  activeColor: DakkhoColors.primary,
                  onChanged: (v) => setState(() => _storageLimit = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('500 MB', style: TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
                    Text('10 GB', style: TextStyle(fontSize: 10, color: DakkhoColors.textMuted)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('AUTO-MANAGEMENT'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.clock, 'Auto-delete after 30 days', 'Automatically remove expired downloads',
                    _autoDelete, (v) => setState(() => _autoDelete = v)),
                const Divider(height: 1, indent: 56),
                _toggle(LucideIcons.wifi, 'Wi-Fi Only', 'Only download on Wi-Fi networks',
                    _wifiOnly, (v) => setState(() => _wifiOnly = v)),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('DOWNLOAD QUALITY'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _qualityOption('360', '360p · ~50 MB/hr'),
                const Divider(height: 1, indent: 56),
                _qualityOption('480', '480p · ~100 MB/hr'),
                const Divider(height: 1, indent: 56),
                _qualityOption('720', '720p · ~250 MB/hr'),
                const Divider(height: 1, indent: 56),
                _qualityOption('1080', '1080p HD · ~500 MB/hr'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),
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

  Widget _qualityOption(String value, String label) {
    return RadioListTile<String>(
      value: value, groupValue: _downloadQuality,
      onChanged: (v) => setState(() => _downloadQuality = v ?? '720'),
      title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      activeColor: DakkhoColors.primary,
    );
  }
}
