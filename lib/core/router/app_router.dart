import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/stores/auth_store.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/home/home_page.dart';
import '../../features/explore/explore_page.dart';
import '../../features/search/search_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/course/course_detail_page.dart';
import '../../features/video/video_player_page.dart';
import '../../features/downloads/downloads_page.dart';
import '../../features/device/device_settings_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/error/not_found_page.dart';
import '../../shared/layouts/app_shell.dart';

/// DAKKHO Academy — Router
///
/// Port of web app's useNavigationStore (137 routes).
/// Flutter uses go_router (declarative) instead of Zustand's imperative pushState.
///
/// Auth redirect logic:
///   - All /app/* routes require authentication
///   - /login, /signup, /forgot-password redirect to /app/home if already logged in
///   - On force-logout, redirect to /login with reason param

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      // If not logged in and trying to access /app/*, redirect to login
      if (!isLoggedIn && state.matchedLocation.startsWith('/app/')) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // If logged in and trying to access auth routes, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/app/home';
      }

      return null;
    },
    routes: [
      // ─── Auth Routes (no shell) ───
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ─── App Routes (with shell) ───
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Main
          GoRoute(path: '/app/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/app/explore', builder: (_, __) => const ExplorePage()),
          GoRoute(path: '/app/search', builder: (_, __) => const SearchPage()),
          GoRoute(path: '/app/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/app/profile', builder: (_, __) => const ProfilePage()),

          // Course
          GoRoute(
            path: '/app/course/:id',
            builder: (_, state) => CourseDetailPage(
              courseId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/app/course/:courseId/video/:videoId',
            builder: (_, state) => VideoPlayerPage(
              courseId: state.pathParameters['courseId']!,
              videoId: state.pathParameters['videoId']!,
            ),
          ),

          // Downloads (app-only feature — never visible on web)
          GoRoute(path: '/app/downloads', builder: (_, __) => const DownloadsPage()),

          // Device binding (Settings sub-page)
          GoRoute(path: '/app/device', builder: (_, __) => const DeviceSettingsPage()),

          // Settings
          GoRoute(path: '/app/settings', builder: (_, __) => const SettingsPage()),

          // TODO: Add remaining 80+ routes here as we port pages in Phase 8.
          // For now, fall through to 404 for any unmapped /app/* route.
        ],
      ),

      // ─── 404 ───
      GoRoute(
        path: '/:rest',
        builder: (context, state) => const NotFoundPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
