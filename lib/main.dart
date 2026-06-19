import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/notifications/onesignal_service.dart';
import 'core/storage/secure_storage.dart';

/// DAKKHO Academy — Flutter Android App
///
/// LIGHT THEME IS DEFAULT (matches web app :root).
/// Stack: 100% Cloudflare + OneSignal. NO Firebase dependency.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Initialize OneSignal ───
  await OneSignalService.init();

  // ─── Initialize SecureStorage BEFORE runApp ───
  // This fixes the "SecureStorage not ready" error that was blocking login.
  // All providers that need SecureStorage can now read it synchronously.
  final secureStorage = await SecureStorage.create();

  // ─── Lock to portrait ───
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ─── Status bar for light theme ───
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFF0F9FF),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // ─── Run app with SecureStorage pre-initialized ───
  runApp(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secureStorage),
      ],
      child: const DakkhoApp(),
    ),
  );
}
