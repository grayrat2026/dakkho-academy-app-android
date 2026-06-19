import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/models.dart';

/// Comprehensive API client for all 25 endpoint groups (57 endpoints).
///
/// Port of web app's src/lib/api-client.ts — every endpoint group is here.
/// Each group is a separate class for organization, but they all share
/// the same Dio instance via the dioProvider.

// ─────────────────────────────────────────────────────────────
// Course API
// ─────────────────────────────────────────────────────────────
class CourseApi {
  CourseApi(this._dio);
  final Dio _dio;

  Future<({List<CourseModel> courses, int total})> list({
    String? technology,
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? level,
    String? search,
  }) async {
    final res = await _dio.get('/api/courses', queryParameters: {
      if (technology != null) 'technology': technology,
      if (categoryId != null) 'categoryId': categoryId,
      if (level != null) 'level': level,
      if (search != null) 'search': search,
      'limit': limit,
      'offset': offset,
    });
    final data = res.data as Map<String, dynamic>;
    final courses = (data['courses'] as List<dynamic>?)
        ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (courses: courses, total: (data['total'] as int?) ?? courses.length);
  }

  Future<({CourseModel course, List<InstructorModel> instructors})> get(String id) async {
    final res = await _dio.get('/api/courses/$id');
    final data = res.data as Map<String, dynamic>;
    return (
      course: CourseModel.fromJson(data['course'] as Map<String, dynamic>),
      instructors: (data['instructors'] as List<dynamic>?)
          ?.map((e) => InstructorModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Future<List<VideoModel>> videos(String courseId) async {
    final res = await _dio.get('/api/courses/$courseId/videos');
    final data = res.data as Map<String, dynamic>;
    return (data['videos'] as List<dynamic>?)
        ?.map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
}

// ─────────────────────────────────────────────────────────────
// Instructor API
// ─────────────────────────────────────────────────────────────
class InstructorApi {
  InstructorApi(this._dio);
  final Dio _dio;

  Future<({List<InstructorModel> instructors, int total})> list({
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final res = await _dio.get('/api/instructors', queryParameters: {
      if (search != null) 'search': search,
      'limit': limit,
      'offset': offset,
    });
    final data = res.data as Map<String, dynamic>;
    final instructors = (data['instructors'] as List<dynamic>?)
        ?.map((e) => InstructorModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (instructors: instructors, total: (data['total'] as int?) ?? instructors.length);
  }

  Future<InstructorModel> get(String id) async {
    final res = await _dio.get('/api/instructors/$id');
    final data = res.data as Map<String, dynamic>;
    return InstructorModel.fromJson(data['instructor'] as Map<String, dynamic>);
  }
}

// ─────────────────────────────────────────────────────────────
// Enrollment API
// ─────────────────────────────────────────────────────────────
class EnrollmentApi {
  EnrollmentApi(this._dio);
  final Dio _dio;

  Future<List<EnrollmentModel>> mine() async {
    final res = await _dio.get('/api/enrollments/mine');
    final data = res.data as Map<String, dynamic>;
    return (data['enrollments'] as List<dynamic>?)
        ?.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  Future<({bool enrolled, String paymentStatus})> check(String courseId) async {
    final res = await _dio.get('/api/enrollments/check', queryParameters: {'course_id': courseId});
    final data = res.data as Map<String, dynamic>;
    return (
      enrolled: (data['enrolled'] as bool?) ?? false,
      paymentStatus: (data['paymentStatus'] as String?) ?? 'none',
    );
  }

  Future<void> enroll({required String courseId, String? packageId}) async {
    await _dio.post('/api/enroll', data: {
      'course_id': courseId,
      if (packageId != null) 'package_id': packageId,
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Watch History API
// ─────────────────────────────────────────────────────────────
class WatchHistoryApi {
  WatchHistoryApi(this._dio);
  final Dio _dio;

  Future<({List<WatchHistoryEntry> history, int total})> list({int limit = 50, int offset = 0}) async {
    final res = await _dio.get('/api/watch-history', queryParameters: {'limit': limit, 'offset': offset});
    final data = res.data as Map<String, dynamic>;
    final history = (data['history'] as List<dynamic>?)
        ?.map((e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (history: history, total: (data['total'] as int?) ?? history.length);
  }

  Future<void> upsert({
    required String videoId,
    String? videoTitle,
    String? courseId,
    num? progress,
    int? lastPosition,
    int? duration,
  }) async {
    await _dio.post('/api/watch-history', data: {
      'videoId': videoId,
      if (videoTitle != null) 'videoTitle': videoTitle,
      if (courseId != null) 'courseId': courseId,
      if (progress != null) 'progress': progress,
      if (lastPosition != null) 'lastPosition': lastPosition,
      if (duration != null) 'duration': duration,
    });
  }

  Future<void> clear() async => _dio.delete('/api/watch-history');
  Future<void> delete(String id) async => _dio.delete('/api/watch-history/$id');
}

// ─────────────────────────────────────────────────────────────
// Video API
// ─────────────────────────────────────────────────────────────
class VideoApi {
  VideoApi(this._dio);
  final Dio _dio;

  Future<String> streamUrl({required String key, required String bucket}) async {
    final res = await _dio.get('/api/video/stream-url', queryParameters: {'key': key, 'bucket': bucket});
    return (res.data as Map<String, dynamic>)['url'] as String? ?? '';
  }
}

// ─────────────────────────────────────────────────────────────
// Payment API
// ─────────────────────────────────────────────────────────────
class PaymentApi {
  PaymentApi(this._dio);
  final Dio _dio;

  Future<({String ppId, String ppUrl, int paymentId})> create({
    required int packageId,
    String? couponCode,
    String? duoMemberEmail,
  }) async {
    final res = await _dio.post('/api/payments/create', data: {
      'packageId': packageId,
      if (couponCode != null) 'couponCode': couponCode,
      if (duoMemberEmail != null) 'duoMemberEmail': duoMemberEmail,
    });
    final data = res.data as Map<String, dynamic>;
    return (
      ppId: data['pp_id'] as String? ?? '',
      ppUrl: data['pp_url'] as String? ?? '',
      paymentId: (data['payment_id'] as num?)?.toInt() ?? 0,
    );
  }

  Future<PaymentResult> verify({String? ppId, int? paymentId}) async {
    final res = await _dio.post('/api/payments/verify', data: {
      if (ppId != null) 'pp_id': ppId,
      if (paymentId != null) 'payment_id': paymentId,
    });
    return PaymentResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> config() async {
    final res = await _dio.get('/api/config/payment');
    return res.data as Map<String, dynamic>;
  }

  Future<void> submit({required int packageId, required String trxId, String? phone, String? proofUrl, String? duoMemberEmail}) async {
    await _dio.post('/api/payments/submit', data: {
      'package_id': packageId, 'trx_id': trxId,
      if (phone != null) 'phone': phone,
      if (proofUrl != null) 'proof_url': proofUrl,
      if (duoMemberEmail != null) 'duoMemberEmail': duoMemberEmail,
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Coupon API
// ─────────────────────────────────────────────────────────────
class CouponApi {
  CouponApi(this._dio);
  final Dio _dio;

  Future<Coupon> validate(String code) async {
    final res = await _dio.get('/api/coupons/validate', queryParameters: {'code': code});
    return Coupon.fromJson(res.data as Map<String, dynamic>);
  }
}

// ─────────────────────────────────────────────────────────────
// Profile API
// ─────────────────────────────────────────────────────────────
class ProfileApi {
  ProfileApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> stats() async {
    final res = await _dio.get('/api/student/profile/stats');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> fields) async {
    final res = await _dio.put('/api/student/profile', data: fields);
    return res.data as Map<String, dynamic>;
  }

  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post('/api/student/upload-avatar', data: formData);
    return (res.data as Map<String, dynamic>)['avatarUrl'] as String? ?? '';
  }
}

// ─────────────────────────────────────────────────────────────
// Notification API
// ─────────────────────────────────────────────────────────────
class NotificationApi {
  NotificationApi(this._dio);
  final Dio _dio;

  Future<({List<AppNotification> notifications, int total})> list({int limit = 50, int offset = 0, bool? unread}) async {
    final res = await _dio.get('/api/student/notifications', queryParameters: {
      'limit': limit, 'offset': offset,
      if (unread != null) 'unread': unread,
    });
    final data = res.data as Map<String, dynamic>;
    final notifications = (data['notifications'] as List<dynamic>?)
        ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (notifications: notifications, total: (data['total'] as int?) ?? notifications.length);
  }

  Future<void> markAsRead(String id) async => _dio.put('/api/student/notifications/$id/read');
  Future<void> markAllRead() async => _dio.put('/api/student/notifications/read-all');
}

// ─────────────────────────────────────────────────────────────
// Leaderboard API
// ─────────────────────────────────────────────────────────────
class LeaderboardApi {
  LeaderboardApi(this._dio);
  final Dio _dio;

  Future<({List<LeaderboardEntry> entries, int? yourRank, int yourXp, String period})> get({
    String? technology,
    String period = 'weekly',
    int limit = 50,
  }) async {
    final res = await _dio.get('/api/leaderboard', queryParameters: {
      if (technology != null) 'technology': technology,
      'period': period,
      'limit': limit,
    });
    final data = res.data as Map<String, dynamic>;
    final entries = (data['entries'] as List<dynamic>?)
        ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (
      entries: entries,
      yourRank: data['yourRank'] as int?,
      yourXp: (data['yourXp'] as int?) ?? 0,
      period: data['period'] as String? ?? period,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Achievements API
// ─────────────────────────────────────────────────────────────
class AchievementsApi {
  AchievementsApi(this._dio);
  final Dio _dio;

  Future<({List<Achievement> achievements, int totalXp, int unlockedCount, int totalCount})> get() async {
    final res = await _dio.get('/api/achievements');
    final data = res.data as Map<String, dynamic>;
    final achievements = (data['achievements'] as List<dynamic>?)
        ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (
      achievements: achievements,
      totalXp: (data['totalXp'] as int?) ?? 0,
      unlockedCount: (data['unlockedCount'] as int?) ?? 0,
      totalCount: (data['totalCount'] as int?) ?? achievements.length,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Activity API
// ─────────────────────────────────────────────────────────────
class ActivityApi {
  ActivityApi(this._dio);
  final Dio _dio;

  Future<({List<ActivityEntry> activities, int total})> list({int limit = 50, int offset = 0, String? type}) async {
    final res = await _dio.get('/api/activity', queryParameters: {
      'limit': limit, 'offset': offset,
      if (type != null) 'type': type,
    });
    final data = res.data as Map<String, dynamic>;
    final activities = (data['activities'] as List<dynamic>?)
        ?.map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (activities: activities, total: (data['total'] as int?) ?? activities.length);
  }
}

// ─────────────────────────────────────────────────────────────
// Settings API
// ─────────────────────────────────────────────────────────────
class SettingsApi {
  SettingsApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> getPreferences() async {
    final res = await _dio.get('/api/preferences');
    return (res.data as Map<String, dynamic>)['preferences'] as Map<String, dynamic>? ?? {};
  }

  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    await _dio.put('/api/preferences', data: prefs);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final res = await _dio.get('/api/settings');
    return (res.data as Map<String, dynamic>)['preferences'] as Map<String, dynamic>? ?? {};
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _dio.put('/api/settings', data: settings);
  }
}

// ─────────────────────────────────────────────────────────────
// Learning Stats API
// ─────────────────────────────────────────────────────────────
class LearningStatsApi {
  LearningStatsApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> get({String range = 'week'}) async {
    final res = await _dio.get('/api/student/learning-stats', queryParameters: {'range': range});
    return res.data as Map<String, dynamic>;
  }
}

// ─────────────────────────────────────────────────────────────
// Support API
// ─────────────────────────────────────────────────────────────
class SupportApi {
  SupportApi(this._dio);
  final Dio _dio;

  Future<List<SupportTicket>> listTickets() async {
    final res = await _dio.get('/api/support/tickets');
    final data = res.data as Map<String, dynamic>;
    return (data['tickets'] as List<dynamic>?)
        ?.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }

  Future<({SupportTicket ticket, List<SupportMessage> messages})> getTicket(String ticketId) async {
    final res = await _dio.get('/api/support/tickets/$ticketId');
    final data = res.data as Map<String, dynamic>;
    final ticket = SupportTicket.fromJson(data['ticket'] as Map<String, dynamic>);
    final messages = (data['messages'] as List<dynamic>?)
        ?.map((e) => SupportMessage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (ticket: ticket, messages: messages);
  }

  Future<SupportMessage> sendMessage({required String ticketId, required String message, String? senderType}) async {
    final res = await _dio.post('/api/support/tickets/$ticketId/messages', data: {
      'message': message,
      if (senderType != null) 'sender_type': senderType,
    });
    return SupportMessage.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> createTicket({required String name, required String email, required String subject, required String message}) async {
    final res = await _dio.post('/api/support/tickets', data: {
      'name': name, 'email': email, 'subject': subject, 'message': message,
    });
    return (res.data as Map<String, dynamic>)['message'] as String? ?? '';
  }
}

// ─────────────────────────────────────────────────────────────
// Institute + Technology + Live Class + Event + Package + Push APIs
// ─────────────────────────────────────────────────────────────
class InstituteApi {
  InstituteApi(this._dio);
  final Dio _dio;
  Future<({List<Institute> institutes, int total})> list({String? division, String? search, int page = 1, int limit = 50}) async {
    final res = await _dio.get('/api/institutes', queryParameters: {
      if (division != null) 'division': division,
      if (search != null) 'search': search,
      'page': page, 'limit': limit,
    });
    final data = res.data as Map<String, dynamic>;
    final institutes = (data['institutes'] as List<dynamic>?)
        ?.map((e) => Institute.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return (institutes: institutes, total: (data['total'] as int?) ?? institutes.length);
  }
  Future<Institute> get(int id) async {
    final res = await _dio.get('/api/institutes/$id');
    return Institute.fromJson((res.data as Map<String, dynamic>)['institute'] as Map<String, dynamic>);
  }
  Future<void> requestInstitute({required String name, String? nameBn, String? division, String? district}) async {
    await _dio.post('/api/institutes/requests', data: {
      'institute_name': name,
      if (nameBn != null) 'institute_name_bn': nameBn,
      if (division != null) 'division': division,
      if (district != null) 'district': district,
    });
  }
}

class TechnologyApi {
  TechnologyApi(this._dio);
  final Dio _dio;
  Future<List<Technology>> list() async {
    final res = await _dio.get('/api/technologies');
    final data = res.data as Map<String, dynamic>;
    return (data['technologies'] as List<dynamic>?)
        ?.map((e) => Technology.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
}

class LiveClassApi {
  LiveClassApi(this._dio);
  final Dio _dio;
  Future<List<LiveClass>> list() async {
    final res = await _dio.get('/api/live-classes');
    final data = res.data as Map<String, dynamic>;
    return (data['liveClasses'] as List<dynamic>? ??
        data['live_classes'] as List<dynamic>?)
        ?.map((e) => LiveClass.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
}

class EventApi {
  EventApi(this._dio);
  final Dio _dio;
  Future<List<AppEvent>> list() async {
    final res = await _dio.get('/api/events');
    final data = res.data as Map<String, dynamic>;
    return (data['events'] as List<dynamic>?)
        ?.map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
}

class PackageApi {
  PackageApi(this._dio);
  final Dio _dio;
  Future<List<CoursePackage>> listForCourse(String courseId) async {
    final res = await _dio.get('/api/course-packages', queryParameters: {'courseId': courseId});
    final data = res.data as Map<String, dynamic>;
    return (data['packages'] as List<dynamic>?)
        ?.map((e) => CoursePackage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
  Future<List<UserPackage>> mine() async {
    final res = await _dio.get('/api/packages/mine');
    final data = res.data as Map<String, dynamic>;
    return (data['packages'] as List<dynamic>?)
        ?.map((e) => UserPackage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
  }
}

class PushApi {
  PushApi(this._dio);
  final Dio _dio;
  Future<void> register({required String pushToken, String? deviceType, String? deviceInfo}) async {
    await _dio.post('/api/push/register', data: {
      'push_token': pushToken,
      if (deviceType != null) 'device_type': deviceType,
      if (deviceInfo != null) 'device_info': deviceInfo,
    });
  }
  Future<void> unregister(String pushToken) async {
    await _dio.delete('/api/push/unregister', data: {'push_token': pushToken});
  }
}

class ConfigApi {
  ConfigApi(this._dio);
  final Dio _dio;
  Future<ServerConfig> get() async {
    final res = await _dio.get('/api/config');
    final data = res.data as Map<String, dynamic>;
    return ServerConfig.fromJson(data['config'] as Map<String, dynamic>? ?? data);
  }
}

// ─────────────────────────────────────────────────────────────
// Session API (active login sessions)
// ─────────────────────────────────────────────────────────────
class SessionApi {
  SessionApi(this._dio);
  final Dio _dio;
  Future<List<Map<String, dynamic>>> list() async {
    final res = await _dio.get('/api/sessions');
    final data = res.data as Map<String, dynamic>;
    return (data['sessions'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [];
  }
  Future<void> revoke(String sessionId) async => _dio.delete('/api/sessions/$sessionId');
  Future<void> revokeAll() async => _dio.delete('/api/sessions/revoke-all');
}

// ─────────────────────────────────────────────────────────────
// 2FA API
// ─────────────────────────────────────────────────────────────
class TwoFAApi {
  TwoFAApi(this._dio);
  final Dio _dio;
  Future<Map<String, dynamic>> status() async {
    final res = await _dio.get('/api/2fa/status');
    return res.data as Map<String, dynamic>;
  }
  Future<Map<String, dynamic>> setup() async {
    final res = await _dio.post('/api/2fa/setup');
    return res.data as Map<String, dynamic>;
  }
  Future<void> verifySetup(String code) async {
    await _dio.post('/api/2fa/verify-setup', data: {'code': code});
  }
  Future<void> disable(String code) async {
    await _dio.post('/api/2fa/disable', data: {'code': code});
  }
  Future<void> verify(String code) async {
    await _dio.post('/api/auth/2fa/verify', data: {'code': code});
  }
}

// ─────────────────────────────────────────────────────────────
// Exam Tips API
// ─────────────────────────────────────────────────────────────
class ExamTipsApi {
  ExamTipsApi(this._dio);
  final Dio _dio;
  Future<Map<String, dynamic>> get() async {
    final res = await _dio.get('/api/exam-tips');
    return res.data as Map<String, dynamic>;
  }
}

// ─────────────────────────────────────────────────────────────
// AI Search API
// ─────────────────────────────────────────────────────────────
class AiSearchApi {
  AiSearchApi(this._dio);
  final Dio _dio;
  Future<Map<String, dynamic>> search(String query) async {
    final res = await _dio.post('/api/ai-search', data: {'query': query});
    return res.data as Map<String, dynamic>;
  }
}

// ─────────────────────────────────────────────────────────────
// Riverpod providers — one per API class
// ─────────────────────────────────────────────────────────────
final courseApiProvider = FutureProvider<CourseApi>((ref) async => CourseApi(await ref.watch(dioProvider.future)));
final instructorApiProvider = FutureProvider<InstructorApi>((ref) async => InstructorApi(await ref.watch(dioProvider.future)));
final enrollmentApiProvider = FutureProvider<EnrollmentApi>((ref) async => EnrollmentApi(await ref.watch(dioProvider.future)));
final watchHistoryApiProvider = FutureProvider<WatchHistoryApi>((ref) async => WatchHistoryApi(await ref.watch(dioProvider.future)));
final videoApiProvider = FutureProvider<VideoApi>((ref) async => VideoApi(await ref.watch(dioProvider.future)));
final paymentApiProvider = FutureProvider<PaymentApi>((ref) async => PaymentApi(await ref.watch(dioProvider.future)));
final couponApiProvider = FutureProvider<CouponApi>((ref) async => CouponApi(await ref.watch(dioProvider.future)));
final profileApiProvider = FutureProvider<ProfileApi>((ref) async => ProfileApi(await ref.watch(dioProvider.future)));
final notificationApiProvider = FutureProvider<NotificationApi>((ref) async => NotificationApi(await ref.watch(dioProvider.future)));
final leaderboardApiProvider = FutureProvider<LeaderboardApi>((ref) async => LeaderboardApi(await ref.watch(dioProvider.future)));
final achievementsApiProvider = FutureProvider<AchievementsApi>((ref) async => AchievementsApi(await ref.watch(dioProvider.future)));
final activityApiProvider = FutureProvider<ActivityApi>((ref) async => ActivityApi(await ref.watch(dioProvider.future)));
final settingsApiProvider = FutureProvider<SettingsApi>((ref) async => SettingsApi(await ref.watch(dioProvider.future)));
final learningStatsApiProvider = FutureProvider<LearningStatsApi>((ref) async => LearningStatsApi(await ref.watch(dioProvider.future)));
final supportApiProvider = FutureProvider<SupportApi>((ref) async => SupportApi(await ref.watch(dioProvider.future)));
final instituteApiProvider = FutureProvider<InstituteApi>((ref) async => InstituteApi(await ref.watch(dioProvider.future)));
final technologyApiProvider = FutureProvider<TechnologyApi>((ref) async => TechnologyApi(await ref.watch(dioProvider.future)));
final liveClassApiProvider = FutureProvider<LiveClassApi>((ref) async => LiveClassApi(await ref.watch(dioProvider.future)));
final eventApiProvider = FutureProvider<EventApi>((ref) async => EventApi(await ref.watch(dioProvider.future)));
final packageApiProvider = FutureProvider<PackageApi>((ref) async => PackageApi(await ref.watch(dioProvider.future)));
final pushApiProvider = FutureProvider<PushApi>((ref) async => PushApi(await ref.watch(dioProvider.future)));
final configApiProvider = FutureProvider<ConfigApi>((ref) async => ConfigApi(await ref.watch(dioProvider.future)));
final sessionApiProvider = FutureProvider<SessionApi>((ref) async => SessionApi(await ref.watch(dioProvider.future)));
final twoFAApiProvider = FutureProvider<TwoFAApi>((ref) async => TwoFAApi(await ref.watch(dioProvider.future)));
final examTipsApiProvider = FutureProvider<ExamTipsApi>((ref) async => ExamTipsApi(await ref.watch(dioProvider.future)));
final aiSearchApiProvider = FutureProvider<AiSearchApi>((ref) async => AiSearchApi(await ref.watch(dioProvider.future)));
