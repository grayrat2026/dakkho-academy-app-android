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
import '../../features/profile/edit_profile_page.dart';
import '../../features/profile/change_password_page.dart';
import '../../features/profile/learning_stats_page.dart';
import '../../features/profile/subscription_page.dart';
import '../../features/profile/referral_page.dart';
import '../../features/profile/delete_account_page.dart';
import '../../features/course/course_detail_page.dart';
import '../../features/course/course_curriculum_page.dart';
import '../../features/course/course_reviews_page.dart';
import '../../features/course/course_qa_page.dart';
import '../../features/course/course_announcements_page.dart';
import '../../features/course/course_resources_page.dart';
import '../../features/course/course_notes_page.dart';
import '../../features/course/course_quizzes_page.dart';
import '../../features/course/course_progress_page.dart';
import '../../features/video/video_player_page.dart';
import '../../features/instructor/instructors_page.dart';
import '../../features/instructor/instructor_profile_page.dart';
import '../../features/instructor/instructor_courses_page.dart';
import '../../features/instructor/instructor_reviews_page.dart';
import '../../features/instructor/instructor_schedule_page.dart';
import '../../features/instructor/instructor_contact_page.dart';
import '../../features/my_courses/my_courses_page.dart';
import '../../features/bookmarks/bookmarks_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/settings/account_settings_page.dart';
import '../../features/settings/notification_settings_page.dart';
import '../../features/settings/privacy_settings_page.dart';
import '../../features/settings/language_settings_page.dart';
import '../../features/settings/theme_settings_page.dart';
import '../../features/settings/download_settings_page.dart';
import '../../features/settings/content_protection_page.dart';
import '../../features/settings/active_sessions_page.dart';
import '../../features/settings/video_quality_page.dart';
import '../../features/settings/network_data_page.dart';
import '../../features/help/help_page.dart';
import '../../features/help/faq_page.dart';
import '../../features/help/contact_support_page.dart';
import '../../features/help/report_issue_page.dart';
import '../../features/help/terms_of_service_page.dart';
import '../../features/help/privacy_policy_page.dart';
import '../../features/help/refund_policy_page.dart';
import '../../features/history/watch_history_page.dart';
import '../../features/downloads/downloads_page.dart';
import '../../features/certificates/certificates_page.dart';
import '../../features/live/live_sessions_page.dart';
import '../../features/achievements/achievements_page.dart';
import '../../features/assignment/assignment_page.dart';
import '../../features/discussion/discussion_page.dart';
import '../../features/about/about_page.dart';
import '../../features/departments/department_page.dart';
import '../../features/departments/department_config.dart' show DepartmentConfig;
import '../../features/semesters/semester_page.dart';
import '../../features/exam/exam_prep_page.dart';
import '../../features/exam/exam_schedule_page.dart';
import '../../features/exam/exam_results_page.dart';
import '../../features/exam/exam_practice_page.dart';
import '../../features/exam/exam_tips_page.dart';
import '../../features/social/leaderboard_page.dart';
import '../../features/social/study_groups_page.dart';
import '../../features/social/peer_connections_page.dart';
import '../../features/social/community_page.dart';
import '../../features/social/feedback_page.dart';
import '../../features/social/roadmap_page.dart';
import '../../features/misc/category_page.dart';
import '../../features/misc/pricing_page.dart';
import '../../features/misc/changelog_page.dart';
import '../../features/misc/maintenance_page.dart';
import '../../features/misc/terms_page.dart';
import '../../features/misc/privacy_page.dart';
import '../../features/misc/payment_result_page.dart';
import '../../features/misc/payment_cancel_page.dart';
import '../../features/error/not_found_page.dart';
import '../../features/error/server_error_page.dart';
import '../../shared/layouts/app_shell.dart';

/// DAKKHO Academy — Router
///
/// Port of web app's useNavigationStore (97 routes).
/// Flutter uses go_router (declarative) instead of Zustand's imperative pushState.

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && state.matchedLocation.startsWith('/app/')) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/app/home';
      }
      return null;
    },
    routes: [
      // ─── Auth Routes (no shell) ───
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),

      // ─── App Routes (with shell) ───
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Main
          GoRoute(path: '/app/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/app/explore', builder: (_, __) => const ExplorePage()),
          GoRoute(path: '/app/search', builder: (_, __) => const SearchPage()),
          GoRoute(path: '/app/search/:query', builder: (_, s) => SearchPage(initialQuery: s.pathParameters['query'])),
          GoRoute(path: '/app/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/app/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/app/profile/:userId', builder: (_, s) => ProfilePage(userId: s.pathParameters['userId'])),

          // Course
          GoRoute(path: '/app/course/:courseId', builder: (_, s) => CourseDetailPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/curriculum', builder: (_, s) => CourseCurriculumPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/reviews', builder: (_, s) => CourseReviewsPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/qa', builder: (_, s) => CourseQAPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/announcements', builder: (_, s) => CourseAnnouncementsPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/resources', builder: (_, s) => CourseResourcesPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/notes', builder: (_, s) => CourseNotesPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/quizzes', builder: (_, s) => CourseQuizzesPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/course/:courseId/progress', builder: (_, s) => CourseProgressPage(courseId: s.pathParameters['courseId']!)),
          GoRoute(path: '/app/video/:videoId', builder: (_, s) => VideoPlayerPage(videoId: s.pathParameters['videoId']!)),
          GoRoute(path: '/app/video/:videoId/course/:courseId', builder: (_, s) => VideoPlayerPage(videoId: s.pathParameters['videoId']!, courseId: s.pathParameters['courseId'])),

          // Instructor
          GoRoute(path: '/app/instructors', builder: (_, __) => const InstructorsPage()),
          GoRoute(path: '/app/instructor/:instructorId', builder: (_, s) => InstructorProfilePage(instructorId: s.pathParameters['instructorId']!)),
          GoRoute(path: '/app/instructor/:instructorId/courses', builder: (_, s) => InstructorCoursesPage(instructorId: s.pathParameters['instructorId']!)),
          GoRoute(path: '/app/instructor/:instructorId/reviews', builder: (_, s) => InstructorReviewsPage(instructorId: s.pathParameters['instructorId']!)),
          GoRoute(path: '/app/instructor/:instructorId/schedule', builder: (_, s) => InstructorSchedulePage(instructorId: s.pathParameters['instructorId']!)),
          GoRoute(path: '/app/instructor/:instructorId/contact', builder: (_, s) => InstructorContactPage(instructorId: s.pathParameters['instructorId']!)),

          // User
          GoRoute(path: '/app/my-courses', builder: (_, __) => const MyCoursesPage()),
          GoRoute(path: '/app/bookmarks', builder: (_, __) => const BookmarksPage()),
          GoRoute(path: '/app/history', builder: (_, __) => const WatchHistoryPage()),
          GoRoute(path: '/app/downloads', builder: (_, __) => const DownloadsPage()),
          GoRoute(path: '/app/certificates', builder: (_, __) => const CertificatesPage()),
          GoRoute(path: '/app/live-sessions', builder: (_, __) => const LiveSessionsPage()),
          GoRoute(path: '/app/achievements', builder: (_, __) => const AchievementsPage()),
          GoRoute(path: '/app/assignment', builder: (_, __) => const AssignmentPage()),
          GoRoute(path: '/app/discussion', builder: (_, __) => const DiscussionPage()),
          GoRoute(path: '/app/about', builder: (_, __) => const AboutPage()),

          // Profile sub-pages
          GoRoute(path: '/app/profile/edit', builder: (_, __) => const EditProfilePage()),
          GoRoute(path: '/app/profile/change-password', builder: (_, __) => const ChangePasswordPage()),
          GoRoute(path: '/app/profile/learning-stats', builder: (_, __) => const LearningStatsPage()),
          GoRoute(path: '/app/profile/subscription', builder: (_, __) => const SubscriptionPage()),
          GoRoute(path: '/app/profile/referral', builder: (_, __) => const ReferralPage()),
          GoRoute(path: '/app/profile/delete-account', builder: (_, __) => const DeleteAccountPage()),

          // Settings
          GoRoute(path: '/app/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/app/settings/account', builder: (_, __) => const AccountSettingsPage()),
          GoRoute(path: '/app/settings/notifications', builder: (_, __) => const NotificationSettingsPage()),
          GoRoute(path: '/app/settings/privacy', builder: (_, __) => const PrivacySettingsPage()),
          GoRoute(path: '/app/settings/language', builder: (_, __) => const LanguageSettingsPage()),
          GoRoute(path: '/app/settings/theme', builder: (_, __) => const ThemeSettingsPage()),
          GoRoute(path: '/app/settings/downloads', builder: (_, __) => const DownloadSettingsPage()),
          GoRoute(path: '/app/settings/download-settings', builder: (_, __) => const DownloadSettingsPage()),
          GoRoute(path: '/app/settings/content-protection', builder: (_, __) => const ContentProtectionPage()),
          GoRoute(path: '/app/settings/sessions', builder: (_, __) => const ActiveSessionsPage()),
          GoRoute(path: '/app/settings/video-quality', builder: (_, __) => const VideoQualityPage()),
          GoRoute(path: '/app/settings/network-data', builder: (_, __) => const NetworkDataPage()),
          GoRoute(path: '/app/2fa-setup', builder: (_, __) => const AccountSettingsPage()),
          GoRoute(path: '/app/2fa-disable', builder: (_, __) => const AccountSettingsPage()),

          // Help
          GoRoute(path: '/app/help', builder: (_, __) => const HelpPage()),
          GoRoute(path: '/app/help/faq', builder: (_, __) => const FAQPage()),
          GoRoute(path: '/app/help/contact-support', builder: (_, __) => const ContactSupportPage()),
          GoRoute(path: '/app/help/report-issue', builder: (_, __) => const ReportIssuePage()),
          GoRoute(path: '/app/help/terms-of-service', builder: (_, __) => const TermsOfServicePage()),
          GoRoute(path: '/app/help/privacy-policy', builder: (_, __) => const PrivacyPolicyPage()),
          GoRoute(path: '/app/help/refund-policy', builder: (_, __) => const RefundPolicyPage()),

          // Departments (20)
          for (final entry in DepartmentConfig.all.entries)
            GoRoute(
              path: '/app/department/${entry.key}',
              builder: (_, __) => DepartmentPage(departmentKey: entry.key),
            ),

          // Semesters (8)
          for (var i = 1; i <= 8; i++)
            GoRoute(
              path: '/app/semester/$i',
              builder: (_, __) => SemesterPage(semester: i),
            ),

          // Exam
          GoRoute(path: '/app/exam/prep', builder: (_, __) => const ExamPrepPage()),
          GoRoute(path: '/app/exam/schedule', builder: (_, __) => const ExamSchedulePage()),
          GoRoute(path: '/app/exam/results', builder: (_, __) => const ExamResultsPage()),
          GoRoute(path: '/app/exam/practice', builder: (_, __) => const ExamPracticePage()),
          GoRoute(path: '/app/exam/tips', builder: (_, __) => const ExamTipsPage()),

          // Social
          GoRoute(path: '/app/community/leaderboard', builder: (_, __) => const LeaderboardPage()),
          GoRoute(path: '/app/community/study-groups', builder: (_, __) => const StudyGroupsPage()),
          GoRoute(path: '/app/community/peer-connections', builder: (_, __) => const PeerConnectionsPage()),
          GoRoute(path: '/app/community', builder: (_, __) => const CommunityPage()),
          GoRoute(path: '/app/community/feedback', builder: (_, __) => const FeedbackPage()),
          GoRoute(path: '/app/community/roadmap', builder: (_, __) => const RoadmapPage()),

          // Misc
          GoRoute(path: '/app/category/:categoryId', builder: (_, s) => CategoryPage(categoryId: s.pathParameters['categoryId']!)),
          GoRoute(path: '/app/pricing', builder: (_, __) => const PricingPage()),
          GoRoute(path: '/app/changelog', builder: (_, __) => const ChangelogPage()),
          GoRoute(path: '/app/maintenance', builder: (_, __) => const MaintenancePage()),
          GoRoute(path: '/app/terms', builder: (_, __) => const TermsPage()),
          GoRoute(path: '/app/privacy', builder: (_, __) => const PrivacyPage()),
          GoRoute(path: '/app/payment-result', builder: (_, __) => const PaymentResultPage()),
          GoRoute(path: '/app/payment-cancel', builder: (_, __) => const PaymentCancelPage()),

          // Error
          GoRoute(path: '/app/error/404', builder: (_, __) => const NotFoundPage()),
          GoRoute(path: '/app/error/500', builder: (_, __) => const ServerErrorPage()),
        ],
      ),

      // ─── Top-level 404 ───
      GoRoute(path: '/:rest', builder: (_, __) => const NotFoundPage()),
    ],
    errorBuilder: (_, __) => const NotFoundPage(),
  );
});
