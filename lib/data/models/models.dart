// DAKKHO Academy — Data Models
//
// Port of 16 TypeScript types from web app's api-client.ts + mock-data.ts + apiMappers.ts.
// Plain Dart classes (not Freezed) to avoid build_runner dependency for now —
// we'll migrate to Freezed in Phase 8 if immutability/morphism becomes painful.
//
// All models have fromJson + toJson methods for JSON serialization.

// ─────────────────────────────────────────────────────────────
// User & Auth
// ─────────────────────────────────────────────────────────────

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.instituteId,
    this.instituteName,
    this.technology,
    this.technologyName,
    this.emailVerified = false,
    this.avatarUrl,
    this.packages = const [],
    this.themeMode = 'system',
    this.phone,
    this.bio,
    this.semester,
    this.role = 'student',
  });

  final String id;
  final String name;
  final String email;
  final int? instituteId;
  final String? instituteName;
  final String? technology;
  final String? technologyName;
  final bool emailVerified;
  final String? avatarUrl;
  final List<UserPackage> packages;
  final String themeMode;
  final String? phone;
  final String? bio;
  final int? semester;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    instituteId: json['instituteId'] as int?,
    instituteName: json['instituteName'] as String?,
    technology: json['technology'] as String?,
    technologyName: json['technologyName'] as String?,
    emailVerified: json['emailVerified'] as bool? ?? false,
    avatarUrl: json['avatarUrl'] as String?,
    packages: (json['packages'] as List<dynamic>?)
        ?.map((e) => UserPackage.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    themeMode: json['themeMode'] as String? ?? 'system',
    phone: json['phone'] as String?,
    bio: json['bio'] as String?,
    semester: json['semester'] as int?,
    role: json['role'] as String? ?? 'student',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'instituteId': instituteId,
    'instituteName': instituteName,
    'technology': technology,
    'technologyName': technologyName,
    'emailVerified': emailVerified,
    'avatarUrl': avatarUrl,
    'packages': packages.map((e) => e.toJson()).toList(),
    'themeMode': themeMode,
    'phone': phone,
    'bio': bio,
    'semester': semester,
    'role': role,
  };

  UserModel copyWith({
    String? name, String? email, String? avatarUrl, String? phone,
    String? bio, int? semester, String? technology, int? instituteId,
    String? instituteName, String? technologyName, bool? emailVerified,
    List<UserPackage>? packages, String? themeMode,
  }) => UserModel(
    id: id, name: name ?? this.name, email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl, phone: phone ?? this.phone,
    bio: bio ?? this.bio, semester: semester ?? this.semester,
    technology: technology ?? this.technology,
    instituteId: instituteId ?? this.instituteId,
    instituteName: instituteName ?? this.instituteName,
    technologyName: technologyName ?? this.technologyName,
    emailVerified: emailVerified ?? this.emailVerified,
    packages: packages ?? this.packages,
    themeMode: themeMode ?? this.themeMode,
    role: role,
  );
}

class UserPackage {
  const UserPackage({
    required this.id,
    required this.packageId,
    required this.courseId,
    required this.packageType,
    required this.price,
    required this.durationMonths,
    required this.activatedAt,
    required this.status,
    this.expiresAt,
  });

  final String id;
  final String packageId;
  final String courseId;
  final String packageType;
  final num price;
  final int durationMonths;
  final String activatedAt;
  final String? expiresAt;
  final String status;

  factory UserPackage.fromJson(Map<String, dynamic> json) => UserPackage(
    id: json['id']?.toString() ?? '',
    packageId: json['package_id']?.toString() ?? json['packageId']?.toString() ?? '',
    courseId: json['course_id']?.toString() ?? '',
    packageType: json['package_type'] as String? ?? 'single',
    price: (json['price'] as num?) ?? 0,
    durationMonths: (json['duration_months'] as int?) ?? 0,
    activatedAt: json['activated_at'] as String? ?? '',
    expiresAt: json['expires_at'] as String?,
    status: json['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'package_id': packageId, 'course_id': courseId,
    'package_type': packageType, 'price': price,
    'duration_months': durationMonths, 'activated_at': activatedAt,
    'expires_at': expiresAt, 'status': status,
  };
}

// ─────────────────────────────────────────────────────────────
// Course
// ─────────────────────────────────────────────────────────────

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.thumbnailUrl,
    required this.categoryId,
    required this.instructorId,
    required this.instructorName,
    required this.level,
    required this.language,
    required this.duration,
    required this.totalVideos,
    required this.rating,
    required this.totalReviews,
    required this.totalStudents,
    required this.isFeatured,
    required this.price,
    this.tags = const [],
    this.learningItems = const [],
    this.technologyId,
    this.isPublished = true,
  });

  final String id;
  final String title;
  final String slug;
  final String description;
  final String thumbnailUrl;
  final String categoryId;
  final String instructorId;
  final String instructorName;
  final String level;  // beginner | intermediate | advanced | expert
  final String language;
  final int duration;  // total minutes
  final int totalVideos;
  final num rating;
  final int totalReviews;
  final int totalStudents;
  final bool isFeatured;
  final num price;
  final List<String> tags;
  final List<String> learningItems;
  final String? technologyId;
  final bool isPublished;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // API returns snake_case, web app's apiMappers.ts converts to camelCase.
    // We do the same here.
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? (json['title'] as String? ?? '').toLowerCase().replaceAll(' ', '-'),
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ??
          json['thumbnailUrl'] as String? ??
          json['thumbnail'] as String? ?? '',
      categoryId: json['category_id']?.toString() ??
          json['categoryId']?.toString() ?? '',
      instructorId: json['instructor_id']?.toString() ??
          json['instructorId']?.toString() ?? '',
      instructorName: json['instructor_name'] as String? ??
          json['instructorName'] as String? ?? '',
      level: json['level'] as String? ?? 'beginner',
      language: json['language'] as String? ?? 'bn',
      duration: (json['duration'] as int?) ?? 0,
      totalVideos: (json['total_videos'] as int?) ??
          (json['totalVideos'] as int?) ?? 0,
      rating: (json['rating'] as num?) ?? 0,
      totalReviews: (json['total_reviews'] as int?) ??
          (json['totalReviews'] as int?) ?? 0,
      totalStudents: (json['total_students'] as int?) ??
          (json['totalStudents'] as int?) ?? 0,
      isFeatured: (json['is_featured'] as int?) == 1 ||
          (json['isFeatured'] as bool?) == true,
      price: (json['price'] as num?) ?? 0,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList() ?? [],
      learningItems: (json['learning_items'] as List<dynamic>? ??
          json['learningItems'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList() ?? [],
      technologyId: json['technology_id']?.toString() ??
          json['technologyId']?.toString(),
      isPublished: (json['is_published'] as int?) == 1 ||
          (json['isPublished'] as bool?) == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'slug': slug, 'description': description,
    'thumbnail_url': thumbnailUrl, 'category_id': categoryId,
    'instructor_id': instructorId, 'instructor_name': instructorName,
    'level': level, 'language': language, 'duration': duration,
    'total_videos': totalVideos, 'rating': rating,
    'total_reviews': totalReviews, 'total_students': totalStudents,
    'is_featured': isFeatured ? 1 : 0, 'price': price, 'tags': tags,
    'learning_items': learningItems, 'technology_id': technologyId,
    'is_published': isPublished ? 1 : 0,
  };
}

class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    required this.courseId,
    required this.duration,
    required this.order,
    this.isPreview = false,
    this.description = '',
    this.streamUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.isHls = false,
  });

  final String id;
  final String title;
  final String courseId;
  final int duration;  // seconds
  final int order;
  final bool isPreview;
  final String description;
  final String? streamUrl;
  final String? videoUrl;  // direct mp4 (for preview)
  final String? thumbnailUrl;
  final bool isHls;

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    courseId: json['course_id']?.toString() ?? '',
    duration: (json['duration'] as int?) ?? 0,
    order: (json['order'] as int?) ?? (json['order_index'] as int?) ?? 0,
    isPreview: (json['is_preview'] as int?) == 1 ||
        (json['isPreview'] as bool?) == true,
    description: json['description'] as String? ?? '',
    streamUrl: json['stream_url'] as String?,
    videoUrl: json['video_url'] as String?,
    thumbnailUrl: json['thumbnail_url'] as String?,
    isHls: (json['hls_ready'] as int?) == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'course_id': courseId, 'duration': duration,
    'order': order, 'is_preview': isPreview ? 1 : 0,
    'description': description, 'stream_url': streamUrl,
    'video_url': videoUrl, 'thumbnail_url': thumbnailUrl,
    'hls_ready': isHls ? 1 : 0,
  };
}

// ─────────────────────────────────────────────────────────────
// Enrollment + Watch History
// ─────────────────────────────────────────────────────────────

class EnrollmentModel {
  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.packageId,
    this.expiresAt,
    required this.status,
    required this.progress,
    required this.completed,
    required this.createdAt,
    this.updatedAt,
    required this.course,
  });

  final String id;
  final String userId;
  final String courseId;
  final String? packageId;
  final String? expiresAt;
  final String status;
  final num progress;
  final bool completed;
  final String createdAt;
  final String? updatedAt;
  final CourseModel course;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => EnrollmentModel(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    courseId: json['course_id']?.toString() ?? '',
    packageId: json['package_id']?.toString(),
    expiresAt: json['expires_at'] as String?,
    status: json['status'] as String? ?? 'active',
    progress: (json['progress'] as num?) ?? 0,
    completed: (json['completed'] as num?) == 1 ||
        (json['completed'] as bool?) == true,
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String?,
    course: CourseModel.fromJson({
      'id': json['course_id'],
      'title': json['course_title'],
      'description': json['course_description'],
      'thumbnail_url': json['course_thumbnail'],
      'price': json['course_price'],
      'level': json['course_level'],
      'duration': json['course_duration'],
      'total_videos': json['course_total_videos'],
      'rating': json['course_rating'],
      'is_featured': json['course_is_featured'],
      'technology_id': json['course_technology_id'],
      'is_published': json['is_published'],
    }),
  );
}

class WatchHistoryEntry {
  const WatchHistoryEntry({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.courseId,
    required this.courseName,
    required this.watchedAt,
    required this.progress,
    required this.lastPosition,
    required this.duration,
    this.videoThumbnail = '',
    this.courseThumbnail = '',
  });

  final String id;
  final String videoId;
  final String videoTitle;
  final String courseId;
  final String courseName;
  final String watchedAt;
  final num progress;
  final int lastPosition;
  final int duration;
  final String videoThumbnail;
  final String courseThumbnail;

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) => WatchHistoryEntry(
    id: json['id']?.toString() ?? '',
    videoId: json['video_id']?.toString() ?? json['videoId']?.toString() ?? '',
    videoTitle: json['video_title'] as String? ?? json['videoTitle'] as String? ?? '',
    courseId: json['course_id']?.toString() ?? json['courseId']?.toString() ?? '',
    courseName: json['course_name'] as String? ?? json['courseName'] as String? ?? '',
    watchedAt: json['watched_at'] as String? ?? json['watchedAt'] as String? ?? '',
    progress: (json['progress'] as num?) ?? 0,
    lastPosition: (json['last_position'] as int?) ?? (json['lastPosition'] as int?) ?? 0,
    duration: (json['duration'] as int?) ?? 0,
    videoThumbnail: json['video_thumbnail'] as String? ?? '',
    courseThumbnail: json['course_thumbnail'] as String? ?? '',
  );
}

// ─────────────────────────────────────────────────────────────
// Instructor
// ─────────────────────────────────────────────────────────────

class InstructorModel {
  const InstructorModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    this.coverUrl,
    required this.specialization,
    required this.rating,
    required this.totalStudents,
    required this.totalCourses,
    this.socialLinks = const [],
    this.email,
  });

  final String id;
  final String name;
  final String bio;
  final String avatarUrl;
  final String? coverUrl;
  final String specialization;
  final num rating;
  final int totalStudents;
  final int totalCourses;
  final List<SocialLink> socialLinks;
  final String? email;

  factory InstructorModel.fromJson(Map<String, dynamic> json) => InstructorModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? json['full_name'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String? ??
        json['avatarUrl'] as String? ?? '',
    coverUrl: json['cover_url'] as String?,
    specialization: json['specialization'] as String? ??
        json['title'] as String? ?? '',
    rating: (json['rating'] as num?) ?? 0,
    totalStudents: (json['total_students'] as int?) ?? 0,
    totalCourses: (json['total_courses'] as int?) ?? 0,
    socialLinks: (json['social_links'] as List<dynamic>?)
        ?.map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    email: json['email'] as String?,
  );
}

class SocialLink {
  const SocialLink({required this.platform, required this.url});
  final String platform;
  final String url;

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
    platform: json['platform'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );
}

// ─────────────────────────────────────────────────────────────
// Institute + Technology
// ─────────────────────────────────────────────────────────────

class Institute {
  const Institute({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.division,
    required this.district,
    required this.eiinNumber,
    required this.type,
    required this.isActive,
  });

  final int id;
  final String name;
  final String nameBn;
  final String division;
  final String district;
  final String eiinNumber;
  final String type;
  final bool isActive;

  factory Institute.fromJson(Map<String, dynamic> json) => Institute(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    nameBn: json['name_bn'] as String? ?? '',
    division: json['division'] as String? ?? '',
    district: json['district'] as String? ?? '',
    eiinNumber: json['eiin_number'] as String? ?? '',
    type: json['type'] as String? ?? 'polytechnic',
    isActive: (json['is_active'] as int?) == 1,
  );
}

class Technology {
  const Technology({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.shortCode,
    required this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String nameBn;
  final String shortCode;
  final String description;
  final bool isActive;

  factory Technology.fromJson(Map<String, dynamic> json) => Technology(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    nameBn: json['name_bn'] as String? ?? '',
    shortCode: json['short_code'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isActive: (json['is_active'] as int?) == 1,
  );
}

// ─────────────────────────────────────────────────────────────
// Notifications
// ─────────────────────────────────────────────────────────────

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String message;
  final String type;  // info | success | warning | error | announcement
  final bool read;
  final String createdAt;
  final String? actionUrl;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    type: json['type'] as String? ?? 'info',
    read: (json['read'] as int?) == 1 || (json['read'] as bool?) == true,
    createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
    actionUrl: json['action_url'] as String? ?? json['actionUrl'] as String?,
  );
}

// ─────────────────────────────────────────────────────────────
// Payment
// ─────────────────────────────────────────────────────────────

class CoursePackage {
  const CoursePackage({
    required this.id,
    required this.courseId,
    required this.packageType,
    required this.price,
    required this.durationMonths,
    required this.maxUsers,
    required this.isActive,
    required this.isAutoAssign,
    this.displayName,
    this.description,
  });

  final int id;
  final String courseId;
  final String packageType;  // single | duo | group | lifetime
  final num price;
  final int durationMonths;
  final int maxUsers;
  final bool isActive;
  final bool isAutoAssign;
  final String? displayName;
  final String? description;

  factory CoursePackage.fromJson(Map<String, dynamic> json) => CoursePackage(
    id: (json['id'] as num?)?.toInt() ?? 0,
    courseId: json['course_id']?.toString() ?? '',
    packageType: json['package_type'] as String? ?? 'single',
    price: (json['price'] as num?) ?? 0,
    durationMonths: (json['duration_months'] as int?) ?? 0,
    maxUsers: (json['max_users'] as int?) ?? 1,
    isActive: (json['is_active'] as int?) == 1,
    isAutoAssign: (json['is_auto_assign'] as int?) == 1,
    displayName: json['display_name'] as String?,
    description: json['description'] as String?,
  );
}

class PaymentResult {
  const PaymentResult({
    required this.status,
    required this.amount,
    required this.gateway,
    required this.transactionId,
    this.enrolledCourseId,
    this.message,
  });

  final String status;  // pending | verified | failed | refunded
  final num amount;
  final String gateway;
  final String transactionId;
  final String? enrolledCourseId;
  final String? message;

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
    status: json['status'] as String? ?? 'pending',
    amount: (json['amount'] as num?) ?? 0,
    gateway: json['gateway'] as String? ?? 'piprapay',
    transactionId: json['transaction_id'] as String? ??
        json['transactionId'] as String? ?? '',
    enrolledCourseId: json['enrolled_course_id']?.toString(),
    message: json['message'] as String?,
  );
}

class Coupon {
  const Coupon({
    required this.valid,
    this.coupon,
    this.error,
  });

  final bool valid;
  final CouponData? coupon;
  final String? error;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    valid: json['valid'] as bool? ?? false,
    coupon: json['coupon'] != null
        ? CouponData.fromJson(json['coupon'] as Map<String, dynamic>)
        : null,
    error: json['error'] as String?,
  );
}

class CouponData {
  const CouponData({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.maxUses,
    this.usageCount,
    this.expiresAt,
  });

  final String code;
  final String discountType;  // percentage | fixed
  final num discountValue;
  final int? maxUses;
  final int? usageCount;
  final String? expiresAt;

  factory CouponData.fromJson(Map<String, dynamic> json) => CouponData(
    code: json['code'] as String? ?? '',
    discountType: json['discount_type'] as String? ?? 'percentage',
    discountValue: (json['discount_value'] as num?) ?? 0,
    maxUses: json['max_uses'] as int?,
    usageCount: json['usage_count'] as int?,
    expiresAt: json['expires_at'] as String?,
  );
}

// ─────────────────────────────────────────────────────────────
// Live Class + Event
// ─────────────────────────────────────────────────────────────

class LiveClass {
  const LiveClass({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.technologyId,
    required this.scheduledAt,
    required this.durationMinutes,
    this.meetingUrl,
    this.platform,
    this.status,
    this.recordingUrl,
    this.instructorName,
    this.technologyName,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final String instructorId;
  final int technologyId;
  final String scheduledAt;
  final int durationMinutes;
  final String? meetingUrl;
  final String? platform;
  final String? status;
  final String? recordingUrl;
  final String? instructorName;
  final String? technologyName;

  factory LiveClass.fromJson(Map<String, dynamic> json) => LiveClass(
    id: json['id']?.toString() ?? '',
    courseId: json['course_id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    instructorId: json['instructor_id']?.toString() ?? '',
    technologyId: (json['technology_id'] as int?) ?? 0,
    scheduledAt: json['scheduled_at'] as String? ?? '',
    durationMinutes: (json['duration_minutes'] as int?) ?? 60,
    meetingUrl: json['meeting_url'] as String?,
    platform: json['platform'] as String? ?? 'livekit',
    status: json['status'] as String? ?? 'scheduled',
    recordingUrl: json['recording_url'] as String?,
    instructorName: json['instructor_name'] as String?,
    technologyName: json['technology_name'] as String?,
  );
}

class AppEvent {
  const AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    this.bannerUrl,
    this.isFeatured = false,
  });

  final int id;
  final String title;
  final String description;
  final String eventType;
  final String startDate;
  final String endDate;
  final String? bannerUrl;
  final bool isFeatured;

  factory AppEvent.fromJson(Map<String, dynamic> json) => AppEvent(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    eventType: json['event_type'] as String? ?? 'general',
    startDate: json['start_date'] as String? ?? '',
    endDate: json['end_date'] as String? ?? '',
    bannerUrl: json['banner_url'] as String?,
    isFeatured: (json['is_featured'] as int?) == 1,
  );
}

// ─────────────────────────────────────────────────────────────
// Achievement + Leaderboard + Activity
// ─────────────────────────────────────────────────────────────

class Achievement {
  const Achievement({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameBn,
    required this.description,
    required this.descriptionBn,
    required this.category,
    required this.icon,
    required this.xp,
    required this.unlocked,
    this.unlockedAt,
  });

  final String id;
  final String slug;
  final String name;
  final String nameBn;
  final String description;
  final String descriptionBn;
  final String category;
  final String icon;
  final int xp;
  final bool unlocked;
  final String? unlockedAt;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id']?.toString() ?? '',
    slug: json['slug'] as String? ?? '',
    name: json['name'] as String? ?? '',
    nameBn: json['name_bn'] as String? ?? '',
    description: json['description'] as String? ?? '',
    descriptionBn: json['description_bn'] as String? ?? '',
    category: json['category'] as String? ?? 'general',
    icon: json['icon'] as String? ?? 'award',
    xp: (json['xp'] as int?) ?? 0,
    unlocked: (json['unlocked'] as bool?) ?? (json['unlocked_at'] != null),
    unlockedAt: json['unlocked_at'] as String?,
  );
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.technology,
    required this.xp,
    required this.breakdown,
    required this.activeDays,
  });

  final int rank;
  final String userId;
  final String name;
  final String technology;
  final int xp;
  final XpBreakdown breakdown;
  final int activeDays;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    technology: json['technology'] as String? ?? '',
    xp: (json['xp'] as int?) ?? 0,
    breakdown: XpBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>? ?? {}),
    activeDays: (json['active_days'] as int?) ??
        (json['activeDays'] as int?) ?? 0,
  );
}

class XpBreakdown {
  const XpBreakdown({
    this.video = 0,
    this.quiz = 0,
    this.assignment = 0,
    this.streak = 0,
  });

  final int video;
  final int quiz;
  final int assignment;
  final int streak;

  factory XpBreakdown.fromJson(Map<String, dynamic> json) => XpBreakdown(
    video: (json['video'] as int?) ?? 0,
    quiz: (json['quiz'] as int?) ?? 0,
    assignment: (json['assignment'] as int?) ?? 0,
    streak: (json['streak'] as int?) ?? 0,
  );
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.type,
    required this.resourceType,
    required this.resourceId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String type;
  final String resourceType;
  final String resourceId;
  final String title;
  final String description;
  final String createdAt;
  final Map<String, dynamic> metadata;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
    id: json['id']?.toString() ?? '',
    type: json['type'] as String? ?? '',
    resourceType: json['resource_type'] as String? ?? '',
    resourceId: json['resource_id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    createdAt: json['created_at'] as String? ?? '',
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );
}

// ─────────────────────────────────────────────────────────────
// Support Ticket
// ─────────────────────────────────────────────────────────────

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.ticketId,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.email,
    this.name,
  });

  final String id;
  final String ticketId;
  final String subject;
  final String message;
  final String status;  // open | in_progress | resolved | closed
  final String priority;  // low | medium | high | urgent
  final String createdAt;
  final String? updatedAt;
  final String? category;
  final String? email;
  final String? name;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json['id']?.toString() ?? '',
    ticketId: json['ticket_id'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    message: json['message'] as String? ?? '',
    status: json['status'] as String? ?? 'open',
    priority: json['priority'] as String? ?? 'medium',
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String?,
    category: json['category'] as String?,
    email: json['email'] as String?,
    name: json['name'] as String?,
  );
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.senderType,
    required this.createdAt,
    this.attachments = const [],
  });

  final String id;
  final String ticketId;
  final String message;
  final String senderType;  // user | support | system
  final String createdAt;
  final List<String> attachments;

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
    id: json['id']?.toString() ?? '',
    ticketId: json['ticket_id']?.toString() ?? '',
    message: json['message'] as String? ?? '',
    senderType: json['sender_type'] as String? ?? 'user',
    createdAt: json['created_at'] as String? ?? '',
    attachments: (json['attachments'] as List<dynamic>?)
        ?.map((e) => e.toString()).toList() ?? [],
  );
}

// ─────────────────────────────────────────────────────────────
// Server Config
// ─────────────────────────────────────────────────────────────

class ServerConfig {
  const ServerConfig({
    this.featureToggles = const {},
    this.homePageSections = const {},
    this.sidebarVisibility = const {},
    this.bottomNavTabs = const {},
    this.topBarElements = const {},
    this.cardStyle = 'glass',
    this.contentProtection = const {},
    this.streaming = const { 'maxConcurrentStreams': 1 },
    this.appMinVersion = '1.0.0',
    this.appForceUpdate = false,
  });

  final Map<String, dynamic> featureToggles;
  final Map<String, dynamic> homePageSections;
  final Map<String, dynamic> sidebarVisibility;
  final Map<String, dynamic> bottomNavTabs;
  final Map<String, dynamic> topBarElements;
  final String cardStyle;
  final Map<String, dynamic> contentProtection;
  final Map<String, dynamic> streaming;
  final String appMinVersion;
  final bool appForceUpdate;

  factory ServerConfig.fromJson(Map<String, dynamic> json) => ServerConfig(
    featureToggles: json['featureToggles'] as Map<String, dynamic>? ??
        json['feature_toggles'] as Map<String, dynamic>? ?? {},
    homePageSections: json['homePageSections'] as Map<String, dynamic>? ??
        json['home_page_sections'] as Map<String, dynamic>? ?? {},
    sidebarVisibility: json['sidebarVisibility'] as Map<String, dynamic>? ??
        json['sidebar_visibility'] as Map<String, dynamic>? ?? {},
    bottomNavTabs: json['bottomNavTabs'] as Map<String, dynamic>? ??
        json['bottom_nav_tabs'] as Map<String, dynamic>? ?? {},
    topBarElements: json['topBarElements'] as Map<String, dynamic>? ??
        json['top_bar_elements'] as Map<String, dynamic>? ?? {},
    cardStyle: json['cardStyle'] as String? ?? json['card_style'] as String? ?? 'glass',
    contentProtection: json['contentProtection'] as Map<String, dynamic>? ??
        json['content_protection'] as Map<String, dynamic>? ?? {},
    streaming: json['streaming'] as Map<String, dynamic>? ?? { 'maxConcurrentStreams': 1 },
    appMinVersion: json['appMinVersion'] as String? ??
        json['app_min_version'] as String? ?? '1.0.0',
    appForceUpdate: json['appForceUpdate'] as bool? ??
        json['app_force_update'] as bool? ?? false,
  );

  bool isFeatureEnabled(String feature) =>
      featureToggles[feature] == true || featureToggles[feature] == 1;
}
