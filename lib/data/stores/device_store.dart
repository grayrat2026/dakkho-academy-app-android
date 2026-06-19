import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';

/// Device Store — port of useDeviceStore (new, for Android anti-piracy).
///
/// State:
///   - deviceUuid: String? (app-generated UUID from Keystore)
///   - deviceName: String? (e.g. "Samsung Galaxy A54")
///   - isBound: bool (true after successful /api/device/bind)
///   - lastVerifiedAt: DateTime? (last successful /api/device/verify)
///   - forceLogoutSignal: String? (signal ID if force-logout pending)
///   - cooldownEndsAt: DateTime? (7-day cooldown for self-service switch)
///   - switchCount: int (switches in last 30 days)
///   - isAbuseFlagged: bool

class DeviceState {
  const DeviceState({
    this.deviceUuid,
    this.deviceName,
    this.isBound = false,
    this.lastVerifiedAt,
    this.forceLogoutSignal,
    this.forceLogoutReason,
    this.cooldownEndsAt,
    this.switchCount = 0,
    this.isAbuseFlagged = false,
  });

  final String? deviceUuid;
  final String? deviceName;
  final bool isBound;
  final DateTime? lastVerifiedAt;
  final String? forceLogoutSignal;
  final String? forceLogoutReason;
  final DateTime? cooldownEndsAt;
  final int switchCount;
  final bool isAbuseFlagged;

  bool get hasForceLogout => forceLogoutSignal != null;
  bool get hasCooldown => cooldownEndsAt != null && cooldownEndsAt!.isAfter(DateTime.now());

  DeviceState copyWith({
    String? deviceUuid,
    String? deviceName,
    bool? isBound,
    DateTime? lastVerifiedAt,
    String? forceLogoutSignal,
    String? forceLogoutReason,
    DateTime? cooldownEndsAt,
    int? switchCount,
    bool? isAbuseFlagged,
    bool clearForceLogout = false,
  }) {
    return DeviceState(
      deviceUuid: deviceUuid ?? this.deviceUuid,
      deviceName: deviceName ?? this.deviceName,
      isBound: isBound ?? this.isBound,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      forceLogoutSignal: clearForceLogout ? null : (forceLogoutSignal ?? this.forceLogoutSignal),
      forceLogoutReason: clearForceLogout ? null : (forceLogoutReason ?? this.forceLogoutReason),
      cooldownEndsAt: cooldownEndsAt ?? this.cooldownEndsAt,
      switchCount: switchCount ?? this.switchCount,
      isAbuseFlagged: isAbuseFlagged ?? this.isAbuseFlagged,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  DeviceNotifier(this._storage) : super(const DeviceState());

  final SecureStorage _storage;

  /// Initialize on app start — load device UUID from storage (or generate if missing).
  Future<void> init() async {
    String? uuid = await _storage.getDeviceUuid();
    if (uuid == null) {
      // Generate new UUID v4
      uuid = _generateUuid();
      await _storage.setDeviceUuid(uuid);
    }
    state = state.copyWith(deviceUuid: uuid);
  }

  /// Called after successful /api/device/bind
  void onBindSuccess({required String deviceName}) {
    state = state.copyWith(
      deviceName: deviceName,
      isBound: true,
      lastVerifiedAt: DateTime.now(),
      clearForceLogout: true,
    );
  }

  /// Called after successful /api/device/verify
  void onVerifySuccess() {
    state = state.copyWith(
      lastVerifiedAt: DateTime.now(),
      clearForceLogout: true,
    );
  }

  /// Called when /api/device/verify returns {forceLogout: true}
  void onForceLogoutSignal({required String signalId, required String reason}) {
    state = state.copyWith(
      forceLogoutSignal: signalId,
      forceLogoutReason: reason,
    );
  }

  /// Called after /api/device/status returns cooldown info
  void onStatusUpdate({
    DateTime? cooldownEndsAt,
    int? switchCount,
    bool? isAbuseFlagged,
  }) {
    state = state.copyWith(
      cooldownEndsAt: cooldownEndsAt,
      switchCount: switchCount,
      isAbuseFlagged: isAbuseFlagged,
    );
  }

  /// Clear force-logout signal after Flutter has wiped local data
  void clearForceLogout() {
    state = state.copyWith(clearForceLogout: true);
  }

  String _generateUuid() {
    // Use the uuid package (already in pubspec)
    // For now, generate a v4 UUID manually
    final random = DateTime.now().microsecondsSinceEpoch;
    return '${_hex(random & 0xFFFFFFFF)}-${_hex((random >> 32) & 0xFFFF)}-4${_hex((random >> 48) & 0xFFF)}-a${_hex((random >> 16) & 0xFFF)}-${_hex(random & 0xFFFFFFFFFFFF)}';
  }

  String _hex(int n) => n.toRadixString(16).padLeft(12, '0').substring(0, (n.bitLength + 3) ~/ 4).padLeft(4, '0');
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  return DeviceNotifier(ref.watch(secureStorageProvider).maybeWhen(
    data: (s) => s,
    orElse: () => throw StateError('SecureStorage not ready'),
  ));
});
