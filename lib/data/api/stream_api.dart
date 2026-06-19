import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';

/// StreamApi — client for /api/stream/* endpoints (concurrent stream kill).
class StreamApi {
  StreamApi(this._dio);
  final Dio _dio;

  /// Start streaming a video. Kills any existing active stream for same video on different device.
  Future<StreamStartResult> start({required String videoId}) async {
    final res = await _dio.post('/api/stream/start', data: {'videoId': videoId});
    return StreamStartResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Heartbeat — call every 30s while playing. Returns killed:true if displaced.
  Future<HeartbeatResult> heartbeat({required String streamId}) async {
    final res = await _dio.post('/api/stream/heartbeat', data: {'streamId': streamId});
    return HeartbeatResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Clean end — call when user stops/finishes.
  Future<void> end({required String streamId}) async {
    await _dio.post('/api/stream/end', data: {'streamId': streamId});
  }

  /// Refresh token 30s before expiry.
  Future<StreamStartResult> tokenRefresh({required String streamId}) async {
    final res = await _dio.post('/api/stream/token-refresh', data: {'streamId': streamId});
    return StreamStartResult.fromJson(res.data as Map<String, dynamic>);
  }

  /// Currently active stream (for UI resume).
  Future<ActiveStream?> active() async {
    final res = await _dio.get('/api/stream/active');
    final data = res.data as Map<String, dynamic>;
    if (data['active'] != true) return null;
    return ActiveStream.fromJson(data['stream'] as Map<String, dynamic>);
  }
}

class StreamStartResult {
  const StreamStartResult({
    required this.success,
    required this.streamId,
    required this.hlsUrl,
    required this.token,
    required this.tokenTtl,
    required this.heartbeatInterval,
    required this.expiresAt,
    this.availableQualities = const ['360p'],
    this.concurrentStreamsKilled = 0,
  });

  final bool success;
  final String streamId;
  final String hlsUrl;
  final String token;
  final int tokenTtl;  // seconds (300 = 5 min)
  final int heartbeatInterval;  // seconds (30)
  final String expiresAt;  // ISO 8601
  final List<String> availableQualities;
  final int concurrentStreamsKilled;

  factory StreamStartResult.fromJson(Map<String, dynamic> json) => StreamStartResult(
    success: json['success'] as bool? ?? false,
    streamId: json['streamId'] as String? ?? '',
    hlsUrl: json['hlsUrl'] as String? ?? '',
    token: json['token'] as String? ?? '',
    tokenTtl: json['tokenTtl'] as int? ?? 300,
    heartbeatInterval: json['heartbeatInterval'] as int? ?? 30,
    expiresAt: json['expiresAt'] as String? ?? '',
    availableQualities: (json['availableQualities'] as List? ?? ['360p'])
        .map((e) => e as String)
        .toList(),
    concurrentStreamsKilled: json['concurrentStreamsKilled'] as int? ?? 0,
  );
}

class HeartbeatResult {
  const HeartbeatResult({
    required this.acknowledged,
    this.killed = false,
    this.reason,
    this.message,
    this.nextHeartbeatIn = 30,
  });

  final bool acknowledged;
  final bool killed;
  final String? reason;
  final String? message;
  final int nextHeartbeatIn;

  factory HeartbeatResult.fromJson(Map<String, dynamic> json) => HeartbeatResult(
    acknowledged: json['acknowledged'] as bool? ?? false,
    killed: json['killed'] as bool? ?? false,
    reason: json['reason'] as String?,
    message: json['message'] as String?,
    nextHeartbeatIn: json['nextHeartbeatIn'] as int? ?? 30,
  );
}

class ActiveStream {
  const ActiveStream({
    required this.id,
    required this.videoId,
    required this.deviceUuid,
    required this.startedAt,
    required this.expiresAt,
  });

  final String id;
  final String videoId;
  final String deviceUuid;
  final String startedAt;
  final String expiresAt;

  factory ActiveStream.fromJson(Map<String, dynamic> json) => ActiveStream(
    id: json['id'] as String,
    videoId: json['video_id'] as String,
    deviceUuid: json['device_uuid'] as String? ?? '',
    startedAt: json['started_at'] as String? ?? '',
    expiresAt: json['expires_at'] as String? ?? '',
  );
}

final streamApiProvider = FutureProvider<StreamApi>((ref) async {
  final dio = await ref.watch(dioProvider.future);
  return StreamApi(dio);
});
