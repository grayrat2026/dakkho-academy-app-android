import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/notifications/onesignal_service.dart';

/// DAKKHO Academy — Flutter Android App
///
/// Phase 1: Scaffold (week 3 of 18)
/// Build command:
///   flutter run --flavor dev --dart-define-from-file=.env.dev
///   flutter run --flavor staging --dart-define-from-file=.env.staging
///   flutter run --flavor prod --dart-define-from-file=.env.prod
///
/// Build APK/AAB:
///   flutter build apk --flavor prod --release --dart-define-from-file=.env.prod
///   flutter build appbundle --flavor prod --release --dart-define-from-file=.env.prod
///
/// Stack: 100% Cloudflare + OneSignal. NO Firebase dependency.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Initialize OneSignal (push notifications — no Firebase needed) ───
  await OneSignalService.init();

  // Lock to portrait orientation (video player can request landscape when needed)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set dark status bar by default
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F172A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: DakkhoApp()));
}
