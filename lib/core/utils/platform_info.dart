import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// PlatformInfo — provides device + app info for /api/device/bind payloads.
///
/// Replaces web app's navigator.userAgent parsing (which doesn't apply to Flutter).
class PlatformInfo {
  PlatformInfo._();

  static final _deviceInfo = DeviceInfoPlugin();

  /// Returns device info map for /api/device/bind
  static Future<Map<String, String>> getDeviceInfo() async {
    if (!Platform.isAndroid) {
      return {'deviceName': 'Unknown', 'deviceModel': 'Unknown', 'androidVersion': '0'};
    }

    final info = await _deviceInfo.androidInfo;
    final packageInfo = await PackageInfo.fromPlatform();

    return {
      'deviceName': '${info.brand} ${info.model}',
      'deviceModel': info.model,
      'androidVersion': info.version.release,
      'sdkInt': '${info.version.sdkInt}',
      'manufacturer': info.manufacturer,
      'brand': info.brand,
      'appVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
      'appFlavor': const String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod'),
      'osLanguage': Platform.localeName,
    };
  }

  /// Quick app version string
  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }
}
