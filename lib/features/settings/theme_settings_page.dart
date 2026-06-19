import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/stores/theme_store.dart';
import '../../shared/widgets/glass_card.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme mode selection
          Text('Appearance',
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: DakkhoColors.textSecondary, letterSpacing: 0.5,
              )),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _ThemeOption(
                  icon: LucideIcons.sun,
                  title: 'Light',
                  subtitle: 'Bright background, dark text',
                  selected: themeState.themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
                  preview: const _ThemePreview(isDark: false),
                ),
                _ThemeOption(
                  icon: LucideIcons.moon,
                  title: 'Dark',
                  subtitle: 'Dark background, light text',
                  selected: themeState.themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
                  preview: const _ThemePreview(isDark: true),
                ),
                _ThemeOption(
                  icon: LucideIcons.laptop,
                  title: 'System',
                  subtitle: 'Follow phone setting',
                  selected: themeState.themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
                  preview: _ThemePreview(isDark: MediaQuery.platformBrightnessOf(context) == Brightness.dark),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Live preview
          Text('Live Preview',
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: DakkhoColors.textSecondary, letterSpacing: 0.5,
              )),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: DakkhoColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAKKHO Academy',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary)),
                          Text('Polytechnic Learning',
                              style: TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DakkhoColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Sample course content',
                      style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon, required this.title, required this.subtitle,
    required this.selected, required this.onTap, required this.preview,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? DakkhoColors.primary : DakkhoColors.textSecondary, size: 22),
      title: Text(title,
          style: TextStyle(
            fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? DakkhoColors.primary : DakkhoColors.textPrimary,
          )),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DakkhoColors.textSecondary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 40, height: 30, child: preview),
          const SizedBox(width: 12),
          Icon(selected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: selected ? DakkhoColors.primary : DakkhoColors.textMuted, size: 22),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DakkhoColors.glassCardBorder, width: 1),
      ),
      child: Center(
        child: Container(
          width: 16, height: 4,
          decoration: BoxDecoration(
            color: DakkhoColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
