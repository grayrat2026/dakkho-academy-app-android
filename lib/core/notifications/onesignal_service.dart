import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignalService — initializes OneSignal push notifications.
///
/// WHY NO FIREBASE?
///   OneSignal's Android SDK uses FCM as transport, but you can use OneSignal's
///   *shared* Firebase project — no google-services.json, no Firebase project of
///   your own needed. This is the same approach the web app uses (CDN-loaded
///   OneSignal SDK with just app_id).
///
/// WHAT ONEIGNAL HANDLES:
///   - Push token registration with OneSignal's shared FCM sender
///   - Notification display (via flutter_local_notifications as fallback)
///   - Notification click → deep link routing
///   - Segments / tags for targeting
///   - In-app messages
///
/// WHAT WE STILL NEED ON BACKEND:
///   - Existing /api/push/register endpoint (already deployed) accepts OneSignal
///     player_id — we just call it after OneSignal init.
///   - Existing /api/notifications/* endpoints for in-app notification list.
class OneSignalService {
  OneSignalService._();

  static bool _initialized = false;
  static final _deepLinkController = StreamController<String>.broadcast();

  /// OneSignal App ID — same as web app (ba6c42b2-...).
  /// Loaded from .env via dart-define.
  static const _appId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: 'ba6c42b2-d564-4254-b422-a2bed67d8b0f',
  );

  /// Initialize OneSignal. Call once on app start (in main.dart).
  static Future<void> init() async {
    if (_initialized) return;

    try {
      OneSignal.initialize(_appId);
      OneSignal.InAppMessages.paused(true);  // Pause until user is logged in

      // Notification click → deep link routing
      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        final url = data?['url'] as String?;
        if (url != null) {
          _deepLinkController.add(url);
        }
      });

      _initialized = true;
      debugPrint('[OneSignal] Initialized with app ID: $_appId');
    } catch (e, st) {
      debugPrint('[OneSignal] Init failed: $e');
      debugPrint(st.toString());
    }
  }

  /// Request notification permission (call after user logs in).
  static Future<bool> requestPermission() async {
    if (!_initialized) return false;
    try {
      final granted = await OneSignal.Notifications.requestPermission(true);
      if (granted) {
        OneSignal.InAppMessages.paused(false);
      }
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Get the OneSignal player_id (push token) for this device.
  static Future<String?> getDevicePlayerId() async {
    if (!_initialized) return null;
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (_) {
      return null;
    }
  }

  /// Set user tag for segmentation.
  static Future<void> setTag(String key, String value) async {
    if (!_initialized) return;
    try {
      OneSignal.User.addTagWithKey(key, value);
    } catch (_) {}
  }

  /// Delete tag.
  static Future<void> deleteTag(String key) async {
    if (!_initialized) return;
    try {
      OneSignal.User.removeTags([key]);
    } catch (_) {}
  }

  /// Set external user ID (the student_id from our backend).
  static Future<void> setExternalUserId(String studentId) async {
    if (!_initialized) return;
    try {
      OneSignal.User.addAlias('student_id', studentId);
    } catch (_) {}
  }

  /// Clear external user ID on logout.
  static Future<void> clearExternalUserId() async {
    if (!_initialized) return;
    try {
      OneSignal.User.removeAlias('student_id');
      OneSignal.InAppMessages.paused(true);
    } catch (_) {}
  }

  /// Stream of deep-link URLs from notification clicks.
  static Stream<String> get deepLinkStream => _deepLinkController.stream;
}
