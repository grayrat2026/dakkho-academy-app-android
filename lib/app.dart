import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/dakkho_theme.dart';
import 'core/router/app_router.dart';
import 'data/stores/theme_store.dart';

/// DAKKHO Academy — Root Widget
class DakkhoApp extends ConsumerWidget {
  const DakkhoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'DAKKHO Academy',
      debugShowCheckedModeBanner: false,
      theme: DakkhoTheme.lightTheme,
      darkTheme: DakkhoTheme.darkTheme,
      themeMode: themeState.themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
