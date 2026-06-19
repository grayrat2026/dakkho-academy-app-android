import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

// Top-level UUID v4 generator
String _uuidV4() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final random = now ^ (now << 13) ^ (now >> 7);
  final buffer = StringBuffer();
  for (var i = 0; i < 32; i++) {
    buffer.write(((random >> (i * 4)) & 0xF).toRadixString(16));
  }
  final hex = buffer.toString();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-4${hex.substring(13, 16)}-a${hex.substring(17, 20)}-${hex.substring(20, 32)}';
}

/// Dio HTTP client configured for DAKKHO API.
///
/// Interceptors (in order):
///   1. AuthInterceptor — injects `Authorization: Bearer <token>` header
///   2. DeviceInterceptor — injects `X-Device-UUID` header
///   3. ForceLogoutInterceptor — on 401 with code `logged_in_elsewhere`,
///      triggers full local data wipe via AuthNotifier.forceLogout()
///   4. RetryInterceptor — exponential backoff for 5xx + network errors (max 3 retries)
///   5. LoggingInterceptor (dev only) — pretty_dio_logger
///
/// Base URL: per-flavor (dev/staging/prod) from dart-define

class DakkhoDio {
  DakkhoDio._(this.dio);

  final Dio dio;

  static Future<DakkhoDio> create({
    required String baseUrl,
    required SecureStorage storage,
    required void Function(String reason) onForceLogout,
    required bool enableLogging,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0'),
        'X-App-Flavor': const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev'),
        'X-Platform': 'android',
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    // ─── Auth Interceptor ───
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // ─── Device UUID Interceptor ───
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? uuid = await storage.getDeviceUuid();
        if (uuid == null) {
          // First-run: generate a UUID v4
          uuid = _uuidV4();
          await storage.setDeviceUuid(uuid);
        }
        options.headers['X-Device-UUID'] = uuid;
        handler.next(options);
      },
    ));

    // ─── Force-Logout Interceptor ───
    // Triggers when /api/device/verify returns forceLogout:true OR
    // when ANY endpoint returns 401 with code 'logged_in_elsewhere'
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        // Check for force-logout signal in response body
        if (response.data is Map) {
          final data = response.data as Map;
          if (data['forceLogout'] == true || data['code'] == 'logged_in_elsewhere') {
            final reason = data['reason'] as String? ?? 'logged_in_elsewhere';
            onForceLogout(reason);
          }
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          final data = error.response?.data;
          if (data is Map && data['code'] == 'logged_in_elsewhere') {
            final reason = data['reason'] as String? ?? 'logged_in_elsewhere';
            onForceLogout(reason);
          }
        }
        handler.next(error);
      },
    ));

    // ─── Retry Interceptor (exponential backoff for 5xx + network errors) ───
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      maxRetries: 3,
      retriesAllowed: (error) =>
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          (error.response?.statusCode ?? 0) >= 500,
    ));

    // ─── Logging (dev only) ───
    if (enableLogging && kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return DakkhoDio._(dio);
  }
}

/// Custom Retry Interceptor with exponential backoff
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.retriesAllowed,
  });

  final Dio dio;
  final int maxRetries;
  final bool Function(DioException) retriesAllowed;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= maxRetries || !retriesAllowed(err)) {
      return handler.next(err);
    }

    err.requestOptions.extra['retry_attempt'] = attempt + 1;

    // Exponential backoff: 1s, 2s, 4s
    final delay = Duration(seconds: 1 << attempt);
    await Future.delayed(delay);

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      onError(e, handler);
    }
  }
}

/// Riverpod providers
final dioProvider = FutureProvider<Dio>((ref) async {
  final storage = ref.watch(secureStorageProvider);  // Now synchronous — no .future needed
  final baseUrl = const String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://dakkho-admin-api.dakkho-admin.workers.dev');
  final enableLogging = const bool.fromEnvironment('ENABLE_DEV_LOGGING', defaultValue: false);

  final dakkhoDio = await DakkhoDio.create(
    baseUrl: baseUrl,
    storage: storage,
    onForceLogout: (reason) {
      // Trigger force-logout via auth store
      ref.read(authForceLogoutProvider.notifier).trigger(reason);
    },
    enableLogging: enableLogging,
  );
  return dakkhoDio.dio;
});

/// Stand-in provider for force-logout triggering.
/// AuthNotifier watches this and calls forceLogout() when triggered.
final authForceLogoutProvider = StateNotifierProvider<_ForceLogoutNotifier, String?>((ref) {
  return _ForceLogoutNotifier();
});

class _ForceLogoutNotifier extends StateNotifier<String?> {
  _ForceLogoutNotifier() : super(null);
  void trigger(String reason) => state = reason;
}
