import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';

/// Auth Store — port of useAuthStore from web app.
///
/// State:
///   - user: User? (null if not logged in)
///   - token: String? (Bearer token from /api/auth/login)
///   - isAuthenticated: bool
///   - isHydrated: bool (true after we've loaded from SecureStorage on app start)
///   - isLoading: bool (true during login/signup/refresh)
///   - isSignupPending: bool (true between signup → OTP verification)
///
/// Persistence:
///   - Token stored in FlutterSecureStorage (Keystore-backed on Android)
///   - User object stored in SharedPreferences (not sensitive)
///   - 30-day rolling expiry (matches backend session TTL)

class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.isHydrated = false,
    this.isLoading = false,
    this.isSignupPending = false,
    this.error,
  });

  final User? user;
  final String? token;
  final bool isAuthenticated;
  final bool isHydrated;
  final bool isLoading;
  final bool isSignupPending;
  final String? error;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isAuthenticated,
    bool? isHydrated,
    bool? isLoading,
    bool? isSignupPending,
    String? error,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      token: clearToken ? null : (token ?? this.token),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isHydrated: isHydrated ?? this.isHydrated,
      isLoading: isLoading ?? this.isLoading,
      isSignupPending: isSignupPending ?? this.isSignupPending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.instituteId,
    this.instituteName,
    this.technology,
    this.technologyName,
    this.emailVerified = false,
    this.avatarUrl,
    this.packages = const [],
    this.themeMode = 'system',
    this.phone,
    this.bio,
    this.semester,
    this.role = 'student',
  });

  final String id;
  final String name;
  final String email;
  final int? instituteId;
  final String? instituteName;
  final String? technology;
  final String? technologyName;
  final bool emailVerified;
  final String? avatarUrl;
  final List<UserPackage> packages;
  final String themeMode;
  final String? phone;
  final String? bio;
  final int? semester;
  final String role;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    instituteId: json['instituteId'] as int?,
    instituteName: json['instituteName'] as String?,
    technology: json['technology'] as String?,
    technologyName: json['technologyName'] as String?,
    emailVerified: json['emailVerified'] as bool? ?? false,
    avatarUrl: json['avatarUrl'] as String?,
    packages: (json['packages'] as List<dynamic>?)
        ?.map((e) => UserPackage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    themeMode: json['themeMode'] as String? ?? 'system',
    phone: json['phone'] as String?,
    bio: json['bio'] as String?,
    semester: json['semester'] as int?,
    role: json['role'] as String? ?? 'student',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'instituteId': instituteId,
    'instituteName': instituteName,
    'technology': technology,
    'technologyName': technologyName,
    'emailVerified': emailVerified,
    'avatarUrl': avatarUrl,
    'packages': packages.map((e) => e.toJson()).toList(),
    'themeMode': themeMode,
    'phone': phone,
    'bio': bio,
    'semester': semester,
    'role': role,
  };

  User copyWith({
    String? name, String? email, String? avatarUrl, String? phone,
    String? bio, int? semester, String? technology, int? instituteId,
    String? instituteName, String? technologyName, bool? emailVerified,
    List<UserPackage>? packages, String? themeMode, String? role,
  }) => User(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    phone: phone ?? this.phone,
    bio: bio ?? this.bio,
    semester: semester ?? this.semester,
    technology: technology ?? this.technology,
    instituteId: instituteId ?? this.instituteId,
    instituteName: instituteName ?? this.instituteName,
    technologyName: technologyName ?? this.technologyName,
    emailVerified: emailVerified ?? this.emailVerified,
    packages: packages ?? this.packages,
    themeMode: themeMode ?? this.themeMode,
    role: role ?? this.role,
  );
}

class UserPackage {
  const UserPackage({
    required this.id,
    required this.packageId,
    required this.packageType,
    required this.price,
    required this.durationMonths,
    required this.status,
    required this.activatedAt,
    this.expiresAt,
  });

  final String id;
  final String packageId;
  final String packageType;
  final num price;
  final int durationMonths;
  final String status;
  final String activatedAt;
  final String? expiresAt;

  factory UserPackage.fromJson(Map<String, dynamic> json) => UserPackage(
    id: json['id'] as String,
    packageId: json['package_id'] as String,
    packageType: json['package_type'] as String,
    price: json['price'] as num,
    durationMonths: json['duration_months'] as int,
    status: json['status'] as String,
    activatedAt: json['activated_at'] as String,
    expiresAt: json['expires_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'package_id': packageId,
    'package_type': packageType,
    'price': price,
    'duration_months': durationMonths,
    'status': status,
    'activated_at': activatedAt,
    'expires_at': expiresAt,
  };
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storage) : super(const AuthState()) {
    _hydrate();
  }

  final SecureStorage _storage;

  /// Load token + user from storage on app start
  Future<void> _hydrate() async {
    try {
      final token = await _storage.getAuthToken();
      final userJson = await _storage.getUser();
      if (token != null && userJson != null) {
        state = state.copyWith(
          token: token,
          user: User.fromJson(userJson),
          isAuthenticated: true,
          isHydrated: true,
        );
      } else {
        state = state.copyWith(isHydrated: true);
      }
    } catch (_) {
      state = state.copyWith(isHydrated: true);
    }
  }

  /// Called after successful /api/auth/login
  Future<void> onLoginSuccess({
    required String token,
    required User user,
  }) async {
    await _storage.setAuthToken(token);
    await _storage.setUser(user.toJson());
    state = state.copyWith(
      token: token,
      user: user,
      isAuthenticated: true,
      isLoading: false,
      clearError: true,
    );
  }

  /// Called after /api/auth/me returns fresh user data
  Future<void> refreshUser(User user) async {
    await _storage.setUser(user.toJson());
    state = state.copyWith(user: user);
  }

  /// Called when user starts signup flow (waits for OTP)
  void setSignupPending(bool pending) {
    state = state.copyWith(isSignupPending: pending);
  }

  /// Force-logout — called when /api/device/verify returns {forceLogout: true}
  /// Wipes ALL local data (downloads, cache, Keystore keys) + redirects to login.
  Future<void> forceLogout() async {
    await _storage.clearAll();
    state = const AuthState(
      isHydrated: true,
      error: 'Account logged in on another device',
    );
  }

  /// Normal logout — user-initiated
  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(isHydrated: true);
  }

  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
  void setError(String? error) =>
      error == null ? state = state.copyWith(clearError: true) : state = state.copyWith(error: error);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
