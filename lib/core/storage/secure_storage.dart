import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SecureStorage — wraps FlutterSecureStorage + SharedPreferences.
///
/// Why two storage backends?
///   - FlutterSecureStorage: Android Keystore-backed, encrypts at rest.
///     Used for: auth token, device UUID (sensitive)
///   - SharedPreferences: plaintext, fast.
///     Used for: user object, theme, language prefs (non-sensitive)
///
/// Both are cleared on logout + on force-logout (single-device enforcement).

class SecureStorage {
  SecureStorage._(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  // Keys
  static const _kAuthToken = 'dakkho_auth_token';
  static const _kUser = 'dakkho_user';
  static const _kDeviceUuid = 'dakkho_device_uuid';
  static const _kThemeMode = 'dakkho_theme_mode';
  static const _kLanguage = 'dakkho_language';
  static const _kOnboardingDone = 'dakkho_onboarding_done';
  static const _kLastForceLogout = 'dakkho_last_force_logout';

  static Future<SecureStorage> create() async {
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final prefs = await SharedPreferences.getInstance();
    return SecureStorage._(secure, prefs);
  }

  // ─── Auth Token (SecureStorage) ───
  Future<String?> getAuthToken() => _secure.read(key: _kAuthToken);
  Future<void> setAuthToken(String token) => _secure.write(key: _kAuthToken, value: token);
  Future<void> deleteAuthToken() => _secure.delete(key: _kAuthToken);

  // ─── User Object (SharedPreferences — non-sensitive profile data) ───
  Future<Map<String, dynamic>?> getUser() async {
    final json = _prefs.getString(_kUser);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    await _prefs.setString(_kUser, jsonEncode(user));
  }

  // ─── Device UUID (SecureStorage) ───
  Future<String?> getDeviceUuid() => _secure.read(key: _kDeviceUuid);
  Future<void> setDeviceUuid(String uuid) => _secure.write(key: _kDeviceUuid, value: uuid);

  // ─── Theme / Language / Onboarding (SharedPreferences) ───
  String getThemeMode() => _prefs.getString(_kThemeMode) ?? 'light';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kThemeMode, mode);

  String getLanguage() => _prefs.getString(_kLanguage) ?? 'en';
  Future<void> setLanguage(String lang) => _prefs.setString(_kLanguage, lang);

  bool isOnboardingDone() => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_kOnboardingDone, true);

  DateTime? getLastForceLogout() {
    final ms = _prefs.getInt(_kLastForceLogout);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
  Future<void> setLastForceLogout(DateTime time) =>
      _prefs.setInt(_kLastForceLogout, time.millisecondsSinceEpoch);

  // ─── Nuclear Option: Clear All (logout / force-logout) ───
  Future<void> clearAll() async {
    await _secure.deleteAll();
    await _prefs.clear();
  }
}

/// Riverpod provider for SecureStorage
final secureStorageProvider = FutureProvider<SecureStorage>((ref) async {
  return await SecureStorage.create();
});
