import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});
  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _appLanguage = 'en';
  String _subtitleLanguage = 'bn';
  double _subtitleSize = 14;

  static const _languages = [
    ('en', 'English', '🇬🇧'),
    ('bn', 'বাংলা (Bengali)', '🇧🇩'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('APP LANGUAGE'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: _languages.map((lang) => RadioListTile<String>(
                value: lang.$1,
                groupValue: _appLanguage,
                onChanged: (v) => setState(() => _appLanguage = v ?? 'en'),
                title: Row(
                  children: [
                    Text(lang.$3, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(lang.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                activeColor: DakkhoColors.primary,
              )).toList(),
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('SUBTITLE LANGUAGE'),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'off', groupValue: _subtitleLanguage,
                  onChanged: (v) => setState(() => _subtitleLanguage = v ?? 'off'),
                  title: const Text('Off', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  activeColor: DakkhoColors.primary,
                ),
                ..._languages.map((lang) => RadioListTile<String>(
                  value: lang.$1, groupValue: _subtitleLanguage,
                  onChanged: (v) => setState(() => _subtitleLanguage = v ?? 'off'),
                  title: Text(lang.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  activeColor: DakkhoColors.primary,
                )),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          _section('SUBTITLE STYLE'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtitle Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
                    Text('${_subtitleSize.round()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.primary)),
                  ],
                ),
                Slider(
                  value: _subtitleSize, min: 10, max: 24, divisions: 14,
                  activeColor: DakkhoColors.primary,
                  onChanged: (v) => setState(() => _subtitleSize = v),
                ),
                // Preview
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Sample subtitle text',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _subtitleSize,
                        fontWeight: FontWeight.w600,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
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
}
