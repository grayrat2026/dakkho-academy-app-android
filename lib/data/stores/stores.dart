import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/apis.dart';
import '../models/models.dart';

/// Watch Progress Store — port of useWatchProgressStore.
/// Tracks per-video progress locally, syncs to server.
class WatchProgressState {
  const WatchProgressState({this.progress = const {}});
  final Map<String, WatchProgress> progress;
}

class WatchProgress {
  const WatchProgress({
    required this.videoId,
    this.courseId,
    this.lastPosition = 0,
    this.progress = 0,
    this.completed = false,
    this.lastWatched,
  });
  final String videoId;
  final String? courseId;
  final int lastPosition;
  final num progress;
  final bool completed;
  final DateTime? lastWatched;
}

class WatchProgressNotifier extends StateNotifier<WatchProgressState> {
  WatchProgressNotifier() : super(const WatchProgressState());
  
  // API is set lazily when needed (avoids FutureProvider dependency in constructor)
  WatchHistoryApi? _api;
  void setApi(WatchHistoryApi api) => _api = _api ?? api;

  void updateProgress(String videoId, {String? courseId, int? lastPosition, num? progress, bool? completed}) {
    final existing = state.progress[videoId] ?? WatchProgress(videoId: videoId, courseId: courseId);
    final updated = WatchProgress(
      videoId: videoId,
      courseId: courseId ?? existing.courseId,
      lastPosition: lastPosition ?? existing.lastPosition,
      progress: progress ?? existing.progress,
      completed: completed ?? existing.completed,
      lastWatched: DateTime.now(),
    );
    state = WatchProgressState(progress: {...state.progress, videoId: updated});
  }

  WatchProgress? getProgress(String videoId) => state.progress[videoId];

  Future<void> syncToServer(String videoId, {String? videoTitle, int? duration}) async {
    if (_api == null) return;
    final p = state.progress[videoId];
    if (p == null) return;
    await _api!.upsert(
      videoId: videoId,
      videoTitle: videoTitle,
      courseId: p.courseId,
      progress: p.progress,
      lastPosition: p.lastPosition,
      duration: duration,
    );
  }

  void clear() => state = const WatchProgressState();
}

final watchProgressProvider = StateNotifierProvider<WatchProgressNotifier, WatchProgressState>((ref) {
  return WatchProgressNotifier();
});

// ─────────────────────────────────────────────────────────────
/// Bookmark Store — port of useBookmarkStore.
/// Bookmarked course IDs.
class BookmarkState {
  const BookmarkState({this.bookmarks = const {}});
  final Set<String> bookmarks;
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier() : super(const BookmarkState());

  void toggleBookmark(String courseId) {
    final updated = Set<String>.from(state.bookmarks);
    if (updated.contains(courseId)) {
      updated.remove(courseId);
    } else {
      updated.add(courseId);
    }
    state = BookmarkState(bookmarks: updated);
  }

  bool isBookmarked(String courseId) => state.bookmarks.contains(courseId);

  void clear() => state = const BookmarkState();
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) => BookmarkNotifier());

// ─────────────────────────────────────────────────────────────
/// Notification Store — port of useNotificationStore.
class NotificationState {
  const NotificationState({this.notifications = const [], this.isLoading = false});
  final List<AppNotification> notifications;
  final bool isLoading;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());
  NotificationApi? _api;
  void setApi(NotificationApi api) => _api = _api ?? api;

  Future<void> fetchFromServer() async {
    if (_api == null) return;
    state = NotificationState(notifications: state.notifications, isLoading: true);
    try {
      final result = await _api!.list();
      state = NotificationState(notifications: result.notifications, isLoading: false);
    } catch (_) {
      state = NotificationState(notifications: state.notifications, isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    if (_api != null) await _api!.markAsRead(id);
    final updated = state.notifications.map((n) => n.id == id
        ? AppNotification(id: n.id, title: n.title, message: n.message, type: n.type, read: true, createdAt: n.createdAt, actionUrl: n.actionUrl)
        : n).toList();
    state = NotificationState(notifications: updated);
  }

  Future<void> markAllRead() async {
    if (_api != null) await _api!.markAllRead();
    final updated = state.notifications.map((n) => AppNotification(id: n.id, title: n.title, message: n.message, type: n.type, read: true, createdAt: n.createdAt, actionUrl: n.actionUrl)).toList();
    state = NotificationState(notifications: updated);
  }

  int unreadCount() => state.notifications.where((n) => !n.read).length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

// ─────────────────────────────────────────────────────────────
/// Search Store — port of useSearchStore.
class SearchState {
  const SearchState({this.query = '', this.recentSearches = const []});
  final String query;
  final List<String> recentSearches;
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String q) => state = SearchState(query: q, recentSearches: state.recentSearches);

  void addRecentSearch(String q) {
    if (q.trim().isEmpty) return;
    final updated = [q, ...state.recentSearches.where((s) => s != q)].take(10).toList();
    state = SearchState(query: state.query, recentSearches: updated);
  }

  void clearRecentSearches() => state = SearchState(query: state.query, recentSearches: const []);
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) => SearchNotifier());

// ─────────────────────────────────────────────────────────────
/// Server Config Store — port of useServerConfigStore.
class ServerConfigState {
  const ServerConfigState({this.config, this.isLoading = false, this.error});
  final ServerConfig? config;
  final bool isLoading;
  final String? error;
}

class ServerConfigNotifier extends StateNotifier<ServerConfigState> {
  ServerConfigNotifier() : super(const ServerConfigState());
  ConfigApi? _api;
  void setApi(ConfigApi api) => _api = _api ?? api;

  Future<void> fetch() async {
    if (_api == null) return;
    state = ServerConfigState(config: state.config, isLoading: true);
    try {
      final config = await _api!.get();
      state = ServerConfigState(config: config, isLoading: false);
    } catch (e) {
      state = ServerConfigState(config: state.config, isLoading: false, error: e.toString());
    }
  }

  bool isFeatureEnabled(String feature) => state.config?.isFeatureEnabled(feature) ?? false;
}

final serverConfigProvider = StateNotifierProvider<ServerConfigNotifier, ServerConfigState>((ref) {
  return ServerConfigNotifier();
});

// ─────────────────────────────────────────────────────────────
/// Content Protection Store — port of useContentProtectionStore.
/// Settings for client-side content protection (mostly overridden by FLAG_SECURE on Android).
class ContentProtectionState {
  const ContentProtectionState({
    this.enabled = true,
    this.noCopy = true,
    this.noRightClick = true,
    this.noScreenshot = true,  // FLAG_SECURE on Android
    this.noPrint = true,
    this.customContextMenu = true,
    this.watermark = true,
    this.dragProtection = true,
  });

  final bool enabled;
  final bool noCopy;
  final bool noRightClick;
  final bool noScreenshot;
  final bool noPrint;
  final bool customContextMenu;
  final bool watermark;
  final bool dragProtection;
}

class ContentProtectionNotifier extends StateNotifier<ContentProtectionState> {
  ContentProtectionNotifier() : super(const ContentProtectionState());

  void setEnabled(bool v) => state = ContentProtectionState(enabled: v, noCopy: state.noCopy, noRightClick: state.noRightClick, noScreenshot: state.noScreenshot, noPrint: state.noPrint, customContextMenu: state.customContextMenu, watermark: state.watermark, dragProtection: state.dragProtection);
  void setNoScreenshot(bool v) => state = ContentProtectionState(enabled: state.enabled, noCopy: state.noCopy, noRightClick: state.noRightClick, noScreenshot: v, noPrint: state.noPrint, customContextMenu: state.customContextMenu, watermark: state.watermark, dragProtection: state.dragProtection);
  void setWatermark(bool v) => state = ContentProtectionState(enabled: state.enabled, noCopy: state.noCopy, noRightClick: state.noRightClick, noScreenshot: state.noScreenshot, noPrint: state.noPrint, customContextMenu: state.customContextMenu, watermark: v, dragProtection: state.dragProtection);
}

final contentProtectionProvider = StateNotifierProvider<ContentProtectionNotifier, ContentProtectionState>((ref) => ContentProtectionNotifier());
