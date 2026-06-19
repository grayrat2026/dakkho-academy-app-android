import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class NetworkDataPage extends StatefulWidget {
  const NetworkDataPage({super.key});
  @override
  State<NetworkDataPage> createState() => _NetworkDataPageState();
}

class _NetworkDataPageState extends State<NetworkDataPage> {
  bool _wifiOnlyDownloads = true;
  bool _dataSaver = false;
  bool _autoplayOnWifi = true;
  bool _autoResumeOnReconnect = true;
  bool _imageCompression = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Network & Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Data usage summary
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: DakkhoColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.wifi, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text('This Month', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('1.2 GB',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                Text('of 5 GB monthly estimate',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 1.2 / 5.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  minHeight: 6,
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 16),

          _section('DOWNLOADS'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.wifi, 'Wi-Fi Only Downloads',
                    'Don\'t download videos on mobile data',
                    _wifiOnlyDownloads, (v) => setState(() => _wifiOnlyDownloads = v)),
                const Divider(height: 1, indent: 56),
                _toggle(LucideIcons.refreshCw, 'Auto-resume on Reconnect',
                    'Resume downloads when network is restored',
                    _autoResumeOnReconnect, (v) => setState(() => _autoResumeOnReconnect = v)),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('STREAMING'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.gauge, 'Data Saver Mode',
                    'Stream at lower quality on mobile data',
                    _dataSaver, (v) => setState(() => _dataSaver = v)),
                const Divider(height: 1, indent: 56),
                _toggle(LucideIcons.playCircle, 'Autoplay on Wi-Fi',
                    'Auto-play next video when on Wi-Fi',
                    _autoplayOnWifi, (v) => setState(() => _autoplayOnWifi = v)),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('CONTENT'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _toggle(LucideIcons.image, 'Compress Images',
                    'Load lower-resolution thumbnails on mobile data',
                    _imageCompression, (v) => setState(() => _imageCompression = v)),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Cache management
          _section('CACHE'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: DakkhoColors.warning, size: 20),
                  title: const Text('Clear Image Cache', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  subtitle: const Text('Free up ~45 MB', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  trailing: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared!'), backgroundColor: DakkhoColors.success),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(LucideIcons.database, color: DakkhoColors.primary, size: 20),
                  title: const Text('Clear All Cache', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                  subtitle: const Text('Free up ~120 MB', style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                  trailing: const Icon(LucideIcons.chevronRight, color: DakkhoColors.textSecondary, size: 18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All cache cleared!'), backgroundColor: DakkhoColors.success),
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
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
