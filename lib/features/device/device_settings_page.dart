import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../data/stores/device_store.dart';

class DeviceSettingsPage extends ConsumerStatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  ConsumerState<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends ConsumerState<DeviceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Device Binding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.smartphone, color: DakkhoColors.primary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deviceState.deviceName ?? 'Unknown Device',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UUID: ${deviceState.deviceUuid?.substring(0, 8) ?? '—'}...',
                              style: const TextStyle(fontSize: 12, color: DakkhoColors.textSecondary, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DakkhoColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DakkhoColors.success),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InfoRow('Status', deviceState.isBound ? 'Bound to your account' : 'Not bound'),
                  _InfoRow('Last verified', deviceState.lastVerifiedAt != null
                      ? '${deviceState.lastVerifiedAt!.hour}:${deviceState.lastVerifiedAt!.minute.toString().padLeft(2, '0')}'
                      : 'Never'),
                  _InfoRow('Switches (30d)', '${deviceState.switchCount}'),
                  _InfoRow('Abuse flagged', deviceState.isAbuseFlagged ? 'Yes' : 'No'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (deviceState.hasCooldown)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock, color: DakkhoColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Switch cooldown active. Try again in ${deviceState.cooldownEndsAt?.difference(DateTime.now()).inDays ?? 0} days.',
                        style: const TextStyle(fontSize: 13, color: DakkhoColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Switch Device',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DakkhoColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will release this device from your account. All downloaded content will be removed. 7-day cooldown applies.',
                      style: TextStyle(fontSize: 13, color: DakkhoColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Switch Device',
                      icon: LucideIcons.refreshCw,
                      onPressed: () async {
                        // TODO: implement switch flow with confirmation dialog
                        // final api = await ref.read(deviceApiProvider.future);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: DakkhoColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DakkhoColors.textPrimary)),
        ],
      ),
    );
  }
}
