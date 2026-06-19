import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../stores/auth_store.dart';

/// AuthApi — client for /api/auth/* endpoints.
class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  /// Login with email + password.
  /// Returns Bearer token + user object.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;

      // Check for error response (status 401, 403, etc.)
      if (res.statusCode != null && res.statusCode! >= 400) {
        return LoginResult.failure(
          data['error'] as String? ?? 'Invalid email or password',
        );
      }

      // Handle 2FA-required response
      if (data['requires2FA'] == true) {
        return LoginResult.requires2FA(
          pendingToken: data['pendingToken'] as String,
          email: data['email'] as String,
        );
      }

      // Check if token + user exist
      if (data['token'] == null || data['user'] == null) {
        return LoginResult.failure(
          data['error'] as String? ?? 'Login failed. Please try again.',
        );
      }

      return LoginResult.success(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // Network error, timeout, etc.
      return LoginResult.failure(
        e.response?.data?['error'] as String? ?? 'Network error: ${e.message}',
      );
    } catch (e) {
      return LoginResult.failure('Unexpected error: $e');
    }
  }

  /// Signup — step 1: create account, sends OTP to email
  Future<SignupResult> signup({
    required String fullName,
    required String email,
    required String password,
    int? instituteId,
    String? technology,
  }) async {
    final res = await _dio.post('/api/auth/signup', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'instituteId': instituteId,
      'technology': technology,
    });
    final data = res.data as Map<String, dynamic>;
    return SignupResult.fromJson(data);
  }

  /// Verify OTP — step 2 of signup OR login with OTP
  Future<VerifyOtpResult> verifyOtp({
    required String email,
    required String otp,
    String? pendingToken,
  }) async {
    final res = await _dio.post('/api/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
      if (pendingToken != null) 'pendingToken': pendingToken,
    });
    final data = res.data as Map<String, dynamic>;
    if (data['success'] == true && data['token'] != null) {
      return VerifyOtpResult.success(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    }
    return VerifyOtpResult.failure(
      error: data['error'] as String? ?? 'Verification failed',
    );
  }

  /// Resend OTP
  Future<void> resendOtp({required String email}) async {
    await _dio.post('/api/auth/resend-otp', data: {'email': email});
  }

  /// Forgot password — sends reset OTP
  Future<void> forgotPassword({required String email}) async {
    await _dio.post('/api/auth/forgot-password', data: {'email': email});
  }

  /// Reset password with OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post('/api/auth/reset-password', data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  /// Logout — invalidate current session
  Future<void> logout() async {
    await _dio.post('/api/auth/logout', data: {});
  }

  /// Get current user (used for app cold-start rehydration)
  Future<User?> me() async {
    try {
      final res = await _dio.get('/api/auth/me');
      final data = res.data as Map<String, dynamic>;
      if (data['user'] != null) {
        return User.fromJson(data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      rethrow;
    }
  }
}

class LoginResult {
  const LoginResult._({
    this.token,
    this.user,
    this.requires2FA = false,
    this.pendingToken,
    this.email,
    this.error,
  });

  final String? token;
  final User? user;
  final bool requires2FA;
  final String? pendingToken;
  final String? email;
  final String? error;

  bool get isSuccess => token != null && user != null;

  factory LoginResult.success({required String token, required User user}) =>
      LoginResult._(token: token, user: user);
  factory LoginResult.requires2FA({required String pendingToken, required String email}) =>
      LoginResult._(requires2FA: true, pendingToken: pendingToken, email: email);
  factory LoginResult.failure(String error) => LoginResult._(error: error);
}

class SignupResult {
  const SignupResult({this.success = false, this.message, this.email});
  final bool success;
  final String? message;
  final String? email;

  factory SignupResult.fromJson(Map<String, dynamic> json) => SignupResult(
    success: json['success'] as bool? ?? false,
    message: json['message'] as String?,
    email: json['email'] as String?,
  );
}

class VerifyOtpResult {
  const VerifyOtpResult._({this.token, this.user, this.error});
  final String? token;
  final User? user;
  final String? error;

  bool get isSuccess => token != null && user != null;

  factory VerifyOtpResult.success({required String token, required User user}) =>
      VerifyOtpResult._(token: token, user: user);
  factory VerifyOtpResult.failure({required String error}) =>
      VerifyOtpResult._(error: error);
}

final authApiProvider = FutureProvider<AuthApi>((ref) async {
  final dio = await ref.watch(dioProvider.future);
  return AuthApi(dio);
});
