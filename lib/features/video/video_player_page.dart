import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../data/api/apis.dart';
import '../../data/api/stream_api.dart';
import '../../data/stores/stores.dart';
import 'universal_video_player.dart';

/// VideoPlayerPage — wires UniversalVideoPlayer to real backend.
///
/// Flow:
///   1. Receives videoId + optional courseId from router
///   2. Calls POST /api/stream/start { videoId } → gets { hlsUrl, streamId, tokenTtl }
///   3. Calls GET /api/courses/:courseId/videos → gets full video list for episodes panel
///   4. Calls GET /api/courses/:courseId → gets course info for title context
///   5. Renders UniversalVideoPlayer with all that data
///   6. Sends heartbeats every 30s while playing
///   7. Sends watch progress every 10s
///   8. Calls POST /api/stream/end on dispose
///   9. On video change: restart from step 2

class VideoPlayerPage extends ConsumerStatefulWidget {
  const VideoPlayerPage({super.key, required this.videoId, this.courseId});

  final String videoId;
  final String? courseId;

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  String? _streamId;
  String? _hlsUrl;
  String _title = 'Loading...';
  List<EpisodeInfo> _episodes = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isBookmarked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Get the course's video list FIRST so we know what's available
      if (widget.courseId != null) {
        try {
          final courseApi = await ref.read(courseApiProvider.future);
          final videos = await courseApi.videos(widget.courseId!);
          _episodes = videos.map((v) => EpisodeInfo(
            id: v.id,
            title: v.title,
            url: '',  // Will be filled in when episode is selected
            thumbnailUrl: v.thumbnailUrl,
            description: v.description,
            duration: v.duration,
          )).toList();
          // Find current index
          _currentIndex = _episodes.indexWhere((e) => e.id == widget.videoId);
          if (_currentIndex < 0) _currentIndex = 0;
        } catch (_) {
          // If we can't load the list, just show single video
          _episodes = [];
          _currentIndex = 0;
        }
      }

      // Start stream for the current video
      await _startStream(widget.videoId);

      // Check bookmark status
      _isBookmarked = ref.read(bookmarkProvider.notifier).isBookmarked(widget.videoId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load video: $e';
      });
    }
  }

  Future<void> _startStream(String videoId) async {
    try {
      final streamApi = await ref.read(streamApiProvider.future);
      final result = await streamApi.start(videoId: videoId);
      _streamId = result.streamId;
      _hlsUrl = result.hlsUrl;

      // If we have episodes, update the current one's URL
      if (_episodes.isNotEmpty && _currentIndex < _episodes.length) {
        _episodes[_currentIndex] = EpisodeInfo(
          id: _episodes[_currentIndex].id,
          title: _episodes[_currentIndex].title,
          url: result.hlsUrl,
          thumbnailUrl: _episodes[_currentIndex].thumbnailUrl,
          description: _episodes[_currentIndex].description,
          duration: _episodes[_currentIndex].duration,
        );
      }

      // Find the video title
      if (_episodes.isNotEmpty && _currentIndex < _episodes.length) {
        _title = _episodes[_currentIndex].title;
      } else {
        // Fallback — try to fetch from course videos endpoint
        if (widget.courseId != null) {
          try {
            final courseApi = await ref.read(courseApiProvider.future);
            final videos = await courseApi.videos(widget.courseId!);
            final video = videos.where((v) => v.id == videoId).firstOrNull;
            if (video != null) {
              _title = video.title;
              if (_episodes.isEmpty) {
                _episodes = [EpisodeInfo(id: video.id, title: video.title, url: result.hlsUrl, description: video.description, duration: video.duration)];
                _currentIndex = 0;
              }
            }
          } catch (_) {
            _title = 'Video';
          }
        } else {
          _title = 'Video';
        }
      }
    } catch (e) {
      throw Exception('Failed to start stream: $e');
    }
  }

  Future<void> _switchEpisode(int index) async {
    if (index < 0 || index >= _episodes.length) return;

    // End current stream
    await _endStream();

    setState(() {
      _currentIndex = index;
      _isLoading = true;
    });

    // Start new stream for the new video
    await _startStream(_episodes[index].id);
    _isBookmarked = ref.read(bookmarkProvider.notifier).isBookmarked(_episodes[index].id);

    setState(() => _isLoading = false);
  }

  Future<void> _endStream() async {
    if (_streamId == null) return;
    try {
      final streamApi = await ref.read(streamApiProvider.future);
      await streamApi.end(streamId: _streamId!);
    } catch (_) {}
    _streamId = null;
  }

  Future<void> _onProgress(double progress, int positionSec, int durationSec) async {
    if (widget.courseId == null) return;
    try {
      final api = await ref.read(watchHistoryApiProvider.future);
      final currentVideoId = _episodes.isNotEmpty ? _episodes[_currentIndex].id : widget.videoId;
      await api.upsert(
        videoId: currentVideoId,
        videoTitle: _title,
        courseId: widget.courseId,
        progress: progress * 100,
        lastPosition: positionSec,
        duration: durationSec,
      );
    } catch (_) {}
  }

  void _toggleBookmark(bool bookmarked) {
    final currentVideoId = _episodes.isNotEmpty ? _episodes[_currentIndex].id : widget.videoId;
    ref.read(bookmarkProvider.notifier).toggleBookmark(currentVideoId);
  }

  @override
  void dispose() {
    _endStream();  // Fire-and-forget — endpoint will get called even if widget is unmounted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: DakkhoColors.primary),
        ),
      );
    }

    if (_error != null || _hlsUrl == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: DakkhoColors.danger, size: 64),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Failed to load video',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/app/home');
                    }
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentEpisode = _episodes.isNotEmpty ? _episodes[_currentIndex] : null;
    final url = currentEpisode?.url.isNotEmpty == true ? currentEpisode!.url : _hlsUrl!;

    return UniversalVideoPlayer(
      videoUrl: url,
      title: _title,
      videos: _episodes,
      currentIndex: _currentIndex,
      // TODO: wire real audio/subtitle tracks when backend exposes them
      // For now, pass empty — DUB/CC buttons will be hidden
      audioTracks: const [],
      subtitleTracks: const [],
      isBookmarked: _isBookmarked,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/app/home');
        }
      },
      onBookmarkToggle: _toggleBookmark,
      onEpisodeSelected: _switchEpisode,
      onProgress: _onProgress,
    );
  }
}
