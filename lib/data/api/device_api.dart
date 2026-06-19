import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';

/// DeviceApi — client for /api/device/* endpoints.
///
/// Endpoints:
///   POST /api/device/bind
///   POST /api/device/verify
///   GET  /api/device/status
///   POST /api/device/switch
///   POST /api/device/ack-force-logout
class DeviceApi {
  DeviceApi(this._dio);
  final Dio _dio;

  /// Bind this device after login. Kicks any prior active device.
  Future<BindResult> bind({required Map<String, String> deviceInfo}) async {
    final res = await _dio.post('/api/device/bind', data: deviceInfo);
    return BindResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Heartbeat — returns forceLogout:true if kicked.
  Future<VerifyResult> verify() async {
    final res = await _dio.post('/api/device/verify', data: {});
    return VerifyResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Status for Settings page
  Future<DeviceStatus> status() async {
    final res = await _dio.get('/api/device/status');
    return DeviceStatus.fromJson(res.data as Map<String, dynamic>);
  }

  /// User-initiated "Switch Device" — 7-day cooldown enforced
  Future<BindResult> switchDevice({required Map<String, String> deviceInfo}) async {
    final res = await _dio.post('/api/device/switch', data: deviceInfo);
    return BindResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Ack force-logout after Flutter has wiped local data
  Future<void> ackForceLogout({String? signalId}) async {
    await _dio.post('/api/device/ack-force-logout', data: {
      if (signalId != null) 'signalId': signalId,
    });
  }
}

class BindResult {
  const BindResult({
    required this.status,
    required this.action,
    required this.deviceId,
    required this.isActive,
    this.previousDeviceKilled = false,
    this.message,
  });

  final String status;
  final String action;  // 'bound' | 'switched' | 'refreshed' | 'noop'
  final String deviceId;
  final bool isActive;
  final bool previousDeviceKilled;
  final String? message;

  factory BindResult.fromJson(Map<String, dynamic> json) => BindResult(
    status: json['status'] as String? ?? 'ok',
    action: json['action'] as String? ?? 'bound',
    deviceId: json['deviceId'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    previousDeviceKilled: json['previousDeviceKilled'] as bool? ?? false,
    message: json['message'] as String?,
  );
}

class VerifyResult {
  const VerifyResult({
    required this.isActive,
    this.forceLogout = false,
    this.reason,
    this.signalId,
    this.message,
  });

  final bool isActive;
  final bool forceLogout;
  final String? reason;
  final String? signalId;
  final String? message;

  factory VerifyResult.fromJson(Map<String, dynamic> json) => VerifyResult(
    isActive: json['isActive'] as bool? ?? false,
    forceLogout: json['forceLogout'] as bool? ?? false,
    reason: json['reason'] as String?,
    signalId: json['signalId'] as String?,
    message: json['message'] as String?,
  );
}

class DeviceStatus {
  const DeviceStatus({
    this.currentDevice,
    this.isCurrentDevice = false,
    this.deviceHistory = const [],
    required this.cooldown,
    required this.abuseFlagged,
    required this.switchesInLast30Days,
  });

  final Map<String, dynamic>? currentDevice;
  final bool isCurrentDevice;
  final List<Map<String, dynamic>> deviceHistory;
  final CooldownInfo cooldown;
  final bool abuseFlagged;
  final int switchesInLast30Days;

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
    currentDevice: json['currentDevice'] as Map<String, dynamic>?,
    isCurrentDevice: json['isCurrentDevice'] as bool? ?? false,
    deviceHistory: (json['deviceHistory'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
    cooldown: CooldownInfo.fromJson(json['cooldown'] as Map<String, dynamic>),
    abuseFlagged: json['abuseFlagged'] as bool? ?? false,
    switchesInLast30Days: json['switchesInLast30Days'] as int? ?? 0,
  );
}

class CooldownInfo {
  const CooldownInfo({this.active = false, this.endsAt, this.daysRemaining = 0});
  final bool active;
  final String? endsAt;
  final int daysRemaining;

  factory CooldownInfo.fromJson(Map<String, dynamic> json) => CooldownInfo(
    active: json['active'] as bool? ?? false,
    endsAt: json['endsAt'] as String?,
    daysRemaining: json['daysRemaining'] as int? ?? 0,
  );
}

final deviceApiProvider = FutureProvider<DeviceApi>((ref) async {
  final dio = await ref.watch(dioProvider.future);
  return DeviceApi(dio);
});
