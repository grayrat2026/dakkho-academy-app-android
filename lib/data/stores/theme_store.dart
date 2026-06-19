import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';

/// Theme Store — port of useThemeStore from web app.
///
/// State:
///   - themeMode: ThemeMode (light / dark / system)
///   - Overrides system theme when user picks explicitly
class ThemeState {
  const ThemeState({this.themeMode = ThemeMode.light});

  final ThemeMode themeMode;

  ThemeState copyWith({ThemeMode? themeMode}) =>
      ThemeState(themeMode: themeMode ?? this.themeMode);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier(this._storage) : super(const ThemeState()) {
    _load();
  }

  final SecureStorage _storage;

  void _load() {
    final mode = _storage.getThemeMode();
    state = ThemeState(
      themeMode: switch (mode) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,  // default is light (matches web app :root)
      },
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setThemeMode(modeStr);
    state = ThemeState(themeMode: mode);
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref.watch(secureStorageProvider).maybeWhen(
    data: (s) => s,
    orElse: () => throw StateError('SecureStorage not ready'),
  ));
});
