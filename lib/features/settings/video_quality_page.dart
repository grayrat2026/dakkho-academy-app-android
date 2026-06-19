import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class VideoQualityPage extends StatefulWidget {
  const VideoQualityPage({super.key});
  @override
  State<VideoQualityPage> createState() => _VideoQualityPageState();
}

class _VideoQualityPageState extends State<VideoQualityPage> {
  String _streamingQuality = 'auto';
  String _downloadQuality = '720';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Video Quality')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('STREAMING QUALITY'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _qualityOption('auto', 'Auto (Recommended)', 'Adapts to your network speed', true),
                const Divider(height: 1, indent: 56),
                _qualityOption('1080', '1080p HD', 'Best quality · ~1.5 GB/hr', false),
                const Divider(height: 1, indent: 56),
                _qualityOption('720', '720p', 'Good quality · ~800 MB/hr', false),
                const Divider(height: 1, indent: 56),
                _qualityOption('480', '480p', 'Standard · ~400 MB/hr', false),
                const Divider(height: 1, indent: 56),
                _qualityOption('360', '360p', 'Data saver · ~200 MB/hr', false),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('DOWNLOAD QUALITY'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _downloadOption('1080', '1080p HD', '~500 MB/hr'),
                const Divider(height: 1, indent: 56),
                _downloadOption('720', '720p', '~250 MB/hr'),
                const Divider(height: 1, indent: 56),
                _downloadOption('480', '480p', '~100 MB/hr'),
                const Divider(height: 1, indent: 56),
                _downloadOption('360', '360p', '~50 MB/hr'),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Data usage info
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.info, size: 18, color: DakkhoColors.primary),
                    const SizedBox(width: 8),
                    const Text('Data Usage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Higher quality videos consume more mobile data. We recommend using Wi-Fi for HD streaming and downloads.',
                  style: TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DakkhoColors.textMuted, letterSpacing: 1.5)),
  );

  Widget _qualityOption(String value, String label, String subtitle, bool recommended) {
    return RadioListTile<String>(
      value: value, groupValue: _streamingQuality,
      onChanged: (v) => setState(() => _streamingQuality = v ?? 'auto'),
      title: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          if (recommended) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: DakkhoColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('BEST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: DakkhoColors.success)),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      activeColor: DakkhoColors.primary,
    );
  }

  Widget _downloadOption(String value, String label, String subtitle) {
    return RadioListTile<String>(
      value: value, groupValue: _downloadQuality,
      onChanged: (v) => setState(() => _downloadQuality = v ?? '720'),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      activeColor: DakkhoColors.primary,
    );
  }
}
