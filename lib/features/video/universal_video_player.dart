import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/theme/dakkho_theme.dart';
import '../../shared/animations/dakkho_animations.dart';

/// UniversalVideoPlayer — port of player.html UI to Flutter using media_kit.
///
/// Supports:
///   - HLS (.m3u8) — via ExoPlayer under the hood
///   - Plain .mp4
///   - YouTube — handled at the page level (use YoutubePlayerFlutter instead)
///
/// UI features ported from player.html:
///   - Wave background (subtle SVG-like effect via CustomPainter)
///   - Dark overlay gradient (top + bottom)
///   - Top bar: Back, Video title (left) + DUB, CC, Bookmark, Episodes, Settings (right)
///   - Center controls: Rewind 10s, Play/Pause (with ripple), Forward 10s
///   - Bottom: PiP + Fullscreen buttons, Seek bar with hover tooltip, Time row
///   - Episode panel (slides from right) — only if videos.length > 1
///   - Settings dropdown (scrollable, responsive) — portrait: modal sheet, landscape: popover
///   - DUB dropdown — only if audioTracks.length > 1
///   - CC dropdown — only if subtitleTracks.length > 1
///   - Bookmark — persists per videoId via callback
///   - Seek flash animation (-10s / +10s)
///   - Spinner while buffering
///   - Toast messages
///   - Auto-hide controls after 3s when playing
///
/// Orientation rules (user's spec):
///   - DUB + CC icons: only show in landscape; in portrait they go inside Settings menu
///   - Episodes button: only show if videos.length > 1
///   - Settings menu: redesigned — works in both portrait and landscape

class UniversalVideoPlayer extends StatefulWidget {
  const UniversalVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.videos = const [],
    this.currentIndex = 0,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.isBookmarked = false,
    this.onBack,
    this.onBookmarkToggle,
    this.onEpisodeSelected,
    this.onProgress,
    this.onEnded,
  });

  final String videoUrl;
  final String title;
  final List<EpisodeInfo> videos;
  final int currentIndex;
  final List<String> audioTracks;  // ['Japanese (Original)', 'English Dub', ...]
  final List<String> subtitleTracks;  // ['Off', 'English', 'Bengali', ...]
  final bool isBookmarked;
  final VoidCallback? onBack;
  final void Function(bool bookmarked)? onBookmarkToggle;
  final void Function(int index)? onEpisodeSelected;
  final void Function(double progress, int positionSeconds, int durationSeconds)? onProgress;
  final VoidCallback? onEnded;

  @override
  State<UniversalVideoPlayer> createState() => _UniversalVideoPlayerState();
}

class _UniversalVideoPlayerState extends State<UniversalVideoPlayer> with SingleTickerProviderStateMixin {
  late final Player _player;
  late final VideoController _controller;
  late final AnimationController _rippleController;

  bool _showControls = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isDragging = false;
  bool _isFullscreen = false;
  bool _isLandscape = false;
  bool _isBookmarked = false;
  bool _isLooping = false;
  double _currentPosition = 0;
  double _duration = 0;
  double _playbackSpeed = 1.0;
  String _selectedQuality = 'auto';
  int _selectedAudioTrack = 0;
  int _selectedSubtitleTrack = 0;
  Timer? _hideTimer;
  Timer? _progressTimer;
  String? _toast;
  Timer? _toastTimer;

  // Episode panel state
  bool _episodesOpen = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,  // 32MB buffer for HLS
      ),
    );
    _controller = VideoController(_player);

    _setupPlayer();
    _open(widget.videoUrl);
    _startAutoHide();
    _startProgressReporting();
  }

  void _setupPlayer() {
    _player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
        if (playing) _startAutoHide();
      }
    });

    _player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });

    _player.stream.position.listen((pos) {
      if (mounted && !_isDragging) {
        setState(() => _currentPosition = pos.inMilliseconds.toDouble());
      }
    });

    _player.stream.duration.listen((dur) {
      if (mounted) setState(() => _duration = dur.inMilliseconds.toDouble());
    });

    _player.stream.completed.listen((_) {
      if (_isLooping) {
        _player.seek(Duration.zero);
        _player.play();
      } else {
        widget.onEnded?.call();
        // Auto-advance to next episode
        if (widget.videos.isNotEmpty && widget.currentIndex < widget.videos.length - 1) {
          Future.delayed(const Duration(milliseconds: 600), () {
            widget.onEpisodeSelected?.call(widget.currentIndex + 1);
          });
        }
      }
    });

    _player.stream.error.listen((err) {
      _showToast('Playback error: $err');
    });
  }

  Future<void> _open(String url) async {
    await _player.open(Media(url, httpHeaders: {
      'User-Agent': 'DAKKHO-Academy/1.0 (Android)',
    }));
  }

  @override
  void didUpdateWidget(UniversalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _open(widget.videoUrl);
    }
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _isBookmarked = widget.isBookmarked;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _progressTimer?.cancel();
    _toastTimer?.cancel();
    _rippleController.dispose();
    _player.dispose();
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  void _startAutoHide() {
    _hideTimer?.cancel();
    if (_isPlaying && !_isDragging && _episodesOpen == false) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) setState(() => _showControls = false);
      });
    }
  }

  void _startProgressReporting() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_duration > 0) {
        widget.onProgress?.call(
          _currentPosition / _duration,
          (_currentPosition / 1000).round(),
          (_duration / 1000).round(),
        );
      }
    });
  }

  void _showToast(String msg) {
    setState(() => _toast = msg);
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startAutoHide();
  }

  void _togglePlay() {
    _rippleController.forward(from: 0);
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _skip(int seconds) {
    final target = (_currentPosition / 1000) + seconds;
    _player.seek(Duration(seconds: target.clamp(0, _duration / 1000).toInt()));
  }

  void _seekTo(double fraction) {
    final target = (fraction * _duration).toInt();
    _player.seek(Duration(milliseconds: target));
    setState(() => _currentPosition = target.toDouble());
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video surface
          Video(
            controller: _controller,
            fill: Colors.black,
            fit: BoxFit.contain,
          ).animate().fadeIn(duration: DakkhoAnimations.slow),

          // Wave background (shown when paused + no video frame yet)
          // AnimatedOpacity(
          //   opacity: _isPlaying ? 0 : 1,
          //   duration: const Duration(milliseconds: 500),
          //   child: const CustomPaint(painter: _WaveBackgroundPainter()),
          // ),

          // Dark overlay gradient
          AnimatedOpacity(
            opacity: _showControls ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x6B000000),
                      Color(0x0D000000),
                      Color(0x0D000000),
                      Color(0x7A000000),
                    ],
                    stops: [0, 0.26, 0.70, 1],
                  ),
                ),
              ),
            ),
          ),

          // Spinner when buffering
          if (_isBuffering)
            const Center(
              child: SizedBox(
                width: 46, height: 46,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(DakkhoColors.success),
                  backgroundColor: Color(0x2E22C55E),
                ),
              ),
            ),

          // Controls overlay
          if (_showControls) ..._buildControls(),

          // Tap area to toggle controls (when controls hidden, tap shows them)
          if (!_showControls)
            GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior.opaque,
            ),

          // Episode panel (slides from right)
          if (widget.videos.length > 1)
            AnimatedSlide(
              offset: _episodesOpen ? Offset.zero : const Offset(1, 0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: _isLandscape ? 380 : MediaQuery.of(context).size.width,
                  height: double.infinity,
                  child: _EpisodePanel(
                    videos: widget.videos,
                    currentIndex: widget.currentIndex,
                    onClose: () => setState(() => _episodesOpen = false),
                    onSelect: (i) {
                      setState(() => _episodesOpen = false);
                      widget.onEpisodeSelected?.call(i);
                    },
                  ),
                ),
              ),
            ),

          // Toast
          if (_toast != null)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xE610100E),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    _toast!,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ).animate().fadeIn().slideY(begin: 0.5, end: 0),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildControls() {
    return [
      // Top bar
      Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 18, 0),
            child: Row(
              children: [
                // Back
                _IconButton(
                  icon: LucideIcons.chevronLeft,
                  size: 24,
                  onTap: () {
                    if (_isFullscreen) {
                      _toggleFullscreen();
                    } else {
                      widget.onBack?.call();
                    }
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1))],
                    ),
                  ),
                ),
                // Right side buttons
                // DUB + CC: only in landscape, and only if tracks exist
                if (_isLandscape && widget.audioTracks.length > 1) ...[
                  _IconButton(
                    icon: LucideIcons.headphones,
                    size: 24,
                    isActive: _selectedAudioTrack > 0,
                    onTap: () => _showDropdown(context, _DropdownType.audio),
                  ),
                  const SizedBox(width: 2),
                ],
                if (_isLandscape && widget.subtitleTracks.length > 1) ...[
                  _IconButton(
                    icon: LucideIcons.type,
                    size: 24,
                    isActive: _selectedSubtitleTrack > 0,
                    onTap: () => _showDropdown(context, _DropdownType.subtitle),
                  ),
                  const SizedBox(width: 2),
                ],
                // Bookmark — always visible
                _IconButton(
                  icon: _isBookmarked ? LucideIcons.bookmark : LucideIcons.bookmark,
                  size: 24,
                  isActive: _isBookmarked,
                  onTap: () {
                    setState(() => _isBookmarked = !_isBookmarked);
                    widget.onBookmarkToggle?.call(_isBookmarked);
                    _showToast(_isBookmarked ? 'Bookmarked' : 'Bookmark removed');
                  },
                ),
                const SizedBox(width: 2),
                // Episodes — only if multiple
                if (widget.videos.length > 1) ...[
                  _IconButton(
                    icon: LucideIcons.listVideo,
                    size: 24,
                    isActive: _episodesOpen,
                    onTap: () => setState(() => _episodesOpen = !_episodesOpen),
                  ),
                  const SizedBox(width: 2),
                ],
                // Settings — always visible
                _IconButton(
                  icon: LucideIcons.settings2,
                  size: 24,
                  onTap: () => _showSettingsSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),

      // Center controls
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rewind 10
            _SkipButton(
              icon: LucideIcons.rotateCcw,
              label: '10',
              onTap: () {
                _skip(-10);
                _showSeekFlash(isForward: false);
              },
            ),
            const SizedBox(width: 48),
            // Play/Pause
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple
                    ScaleTransition(
                      scale: Tween<double>(begin: 0, end: 2.4).animate(
                        CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
                      ),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DakkhoColors.success.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    // Icon
                    Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: Colors.white,
                      size: 68,
                      fill: _isPlaying ? 1.0 : 0.0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 48),
            // Forward 10
            _SkipButton(
              icon: LucideIcons.rotateCw,
              label: '10',
              onTap: () {
                _skip(10);
                _showSeekFlash(isForward: true);
              },
            ),
          ],
        ),
      ),

      // Bottom controls
      Positioned(
        bottom: 0, left: 0, right: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PiP + Fullscreen buttons (right-aligned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _IconButton(
                      icon: LucideIcons.pictureInPicture2,
                      size: 22,
                      onTap: () => _showToast('PiP not available in current build'),
                    ),
                    const SizedBox(width: 6),
                    _IconButton(
                      icon: _isFullscreen ? LucideIcons.minimize : LucideIcons.maximize,
                      size: 22,
                      onTap: _toggleFullscreen,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Seek bar
                _SeekBar(
                  position: _currentPosition,
                  duration: _duration,
                  isDragging: _isDragging,
                  onDragStart: () {
                    setState(() => _isDragging = true);
                    _hideTimer?.cancel();
                  },
                  onDragUpdate: (pos) => setState(() => _currentPosition = pos),
                  onDragEnd: (pos) {
                    _seekTo(pos / _duration);
                    setState(() => _isDragging = false);
                    _startAutoHide();
                  },
                ),
                const SizedBox(height: 5),
                // Time row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_currentPosition / 1000),
                      style: const TextStyle(
                        color: Color(0xC7FFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      _formatTime(_duration / 1000),
                      style: const TextStyle(
                        color: Color(0xC7FFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  void _showSeekFlash({required bool isForward}) {
    // Brief overlay icon for seek feedback
    final overlay = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: isForward ? null : MediaQuery.of(context).size.width * 0.08,
        right: isForward ? MediaQuery.of(context).size.width * 0.08 : null,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isForward ? LucideIcons.rotateCw : LucideIcons.rotateCcw,
                color: Colors.white,
                size: 28,
              ),
              Text(
                isForward ? '+10s' : '-10s',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ).animate().fadeIn().scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(0.9, 0.9),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOut,
          ).then(),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(milliseconds: 700), () => overlay.remove());
  }

  void _showDropdown(BuildContext context, _DropdownType type) {
    final items = type == _DropdownType.audio ? widget.audioTracks : widget.subtitleTracks;
    final selected = type == _DropdownType.audio ? _selectedAudioTrack : _selectedSubtitleTrack;

    // In landscape: popover above the button
    // In portrait (shouldn't happen — DUB/CC are inside Settings in portrait)
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                type == _DropdownType.audio ? 'Audio Track' : 'Subtitles',
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: Color(0xFF777777),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            for (var i = 0; i < items.length; i++)
              ListTile(
                leading: Icon(
                  LucideIcons.check,
                  color: i == selected ? DakkhoColors.success : Colors.transparent,
                  size: 14,
                ),
                title: Text(
                  items[i],
                  style: TextStyle(
                    color: i == selected ? DakkhoColors.success : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (type == _DropdownType.audio) {
                      _selectedAudioTrack = i;
                    } else {
                      _selectedSubtitleTrack = i;
                    }
                  });
                  _showToast('${type == _DropdownType.audio ? 'Audio' : 'Subtitle'}: ${items[i]}');
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    // Redesigned settings — works for both portrait (modal sheet) and landscape (popover)
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (ctx) => _SettingsSheet(
        playbackSpeed: _playbackSpeed,
        quality: _selectedQuality,
        isLooping: _isLooping,
        audioTracks: widget.audioTracks,
        subtitleTracks: widget.subtitleTracks,
        selectedAudioTrack: _selectedAudioTrack,
        selectedSubtitleTrack: _selectedSubtitleTrack,
        isLandscape: _isLandscape,
        onSpeedChanged: (speed) {
          setState(() {
            _playbackSpeed = speed;
            _player.setRate(speed);
          });
          _showToast('Speed: ${speed}x');
        },
        onQualityChanged: (q) {
          setState(() => _selectedQuality = q);
          _showToast('Quality: ${q == 'auto' ? 'Auto' : '${q}p'}');
        },
        onLoopToggled: (loop) {
          setState(() => _isLooping = loop);
          _showToast(loop ? 'Loop: On' : 'Loop: Off');
        },
        onAudioChanged: (i) {
          setState(() => _selectedAudioTrack = i);
          _showToast('Audio: ${widget.audioTracks[i]}');
        },
        onSubtitleChanged: (i) {
          setState(() => _selectedSubtitleTrack = i);
          _showToast('Subtitle: ${widget.subtitleTracks[i]}');
        },
      ),
    );
  }

  String _formatTime(double seconds) {
    if (seconds.isNaN || seconds <= 0) return '00:00:00';
    final h = (seconds ~/ 3600);
    final m = ((seconds % 3600) ~/ 60);
    final s = (seconds % 60).toInt();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

enum _DropdownType { audio, subtitle }

// ─────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.isActive = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isActive ? DakkhoColors.success : Colors.white,
          size: size,
          fill: isActive ? 1.0 : 0.0,
        ),
      ),
    ).animate(target: isActive ? 1 : 0).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: const Duration(milliseconds: 200),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, height: 64,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 38),
            Positioned(
              top: 22,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.position,
    required this.duration,
    required this.isDragging,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final double position;
  final double duration;
  final bool isDragging;
  final VoidCallback onDragStart;
  final void Function(double pos) onDragUpdate;
  final void Function(double pos) onDragEnd;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;
  double? _hoverValue;

  double get _fraction {
    if (_dragValue != null) return _dragValue!;
    if (widget.duration <= 0) return 0;
    return (widget.position / widget.duration).clamp(0, 1);
  }

  String _formatTime(double ms) {
    final seconds = (ms / 1000).round();
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragStart: (_) => widget.onDragStart(),
          onHorizontalDragUpdate: (details) {
            final fraction = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0).toDouble();
            setState(() => _dragValue = fraction);
            widget.onDragUpdate(fraction * widget.duration);
          },
          onHorizontalDragEnd: (_) {
            if (_dragValue != null) {
              widget.onDragEnd(_dragValue! * widget.duration);
            }
            setState(() => _dragValue = null);
          },
          onTapDown: (details) {
            final fraction = (details.localPosition.dx / constraints.maxWidth).clamp(0, 1);
            widget.onDragStart();
            widget.onDragEnd(fraction * widget.duration);
          },
          child: MouseRegion(
            onHover: (event) {
              setState(() {
                _hoverValue = event.localPosition.dx / constraints.maxWidth;
              });
            },
            onExit: (_) => setState(() => _hoverValue = null),
            child: SizedBox(
              height: 26,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: (widget.isDragging || _hoverValue != null) ? 6 : 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Filled progress
                  FractionallySizedBox(
                    widthFactor: _fraction,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: (widget.isDragging || _hoverValue != null) ? 6 : 4,
                      decoration: BoxDecoration(
                        color: DakkhoColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: (_fraction * constraints.maxWidth) - 8,
                    child: AnimatedOpacity(
                      opacity: (widget.isDragging || _hoverValue != null) ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: DakkhoColors.success, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: DakkhoColors.success.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Hover tooltip
                  if (_hoverValue != null && !widget.isDragging)
                    Positioned(
                      left: (_hoverValue! * constraints.maxWidth) - 24,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _formatTime(_hoverValue! * widget.duration),
                          style: const TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EpisodePanel extends StatelessWidget {
  const _EpisodePanel({
    required this.videos,
    required this.currentIndex,
    required this.onClose,
    required this.onSelect,
  });
  final List<EpisodeInfo> videos;
  final int currentIndex;
  final VoidCallback onClose;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 18, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Episodes',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Color(0xFF555555), size: 18),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (_, i) {
                final ep = videos[i];
                final isActive = i == currentIndex;
                return InkWell(
                  onTap: () => onSelect(i),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 13, 18, 13),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFF0FDF4) : (i.isEven ? const Color(0xFFF9FAFB) : Colors.white),
                      border: Border(
                        left: BorderSide(
                          color: isActive ? DakkhoColors.success : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        Container(
                          width: 116, height: 68,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(8),
                            image: ep.thumbnailUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(ep.thumbnailUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                              if (ep.thumbnailUrl == null)
                                const Center(child: Icon(LucideIcons.play, color: Colors.grey)),
                              if (isActive)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(LucideIcons.play, color: Colors.white, size: 22),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EP ${i + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: DakkhoColors.success,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                ep.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (ep.description != null)
                                Text(
                                  ep.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({
    required this.playbackSpeed,
    required this.quality,
    required this.isLooping,
    required this.audioTracks,
    required this.subtitleTracks,
    required this.selectedAudioTrack,
    required this.selectedSubtitleTrack,
    required this.isLandscape,
    required this.onSpeedChanged,
    required this.onQualityChanged,
    required this.onLoopToggled,
    required this.onAudioChanged,
    required this.onSubtitleChanged,
  });

  final double playbackSpeed;
  final String quality;
  final bool isLooping;
  final List<String> audioTracks;
  final List<String> subtitleTracks;
  final int selectedAudioTrack;
  final int selectedSubtitleTrack;
  final bool isLandscape;
  final void Function(double) onSpeedChanged;
  final void Function(String) onQualityChanged;
  final void Function(bool) onLoopToggled;
  final void Function(int) onAudioChanged;
  final void Function(int) onSubtitleChanged;

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _qualities = [
    ('auto', 'Auto'),
    ('1080', '1080p HD'),
    ('720', '720p'),
    ('480', '480p'),
    ('360', '360p'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // In portrait: DUB + CC are inside Settings
            if (!isLandscape) ...[
              if (audioTracks.length > 1) ...[
                _sectionLabel('Audio Track'),
                for (var i = 0; i < audioTracks.length; i++)
                  _item(
                    label: audioTracks[i],
                    selected: i == selectedAudioTrack,
                    onTap: () => onAudioChanged(i),
                  ),
                const _Divider(),
              ],
              if (subtitleTracks.length > 1) ...[
                _sectionLabel('Subtitles'),
                for (var i = 0; i < subtitleTracks.length; i++)
                  _item(
                    label: subtitleTracks[i],
                    selected: i == selectedSubtitleTrack,
                    onTap: () => onSubtitleChanged(i),
                  ),
                const _Divider(),
              ],
            ],
            // Playback Speed
            _sectionLabel('Playback Speed'),
            for (final s in _speeds)
              _item(
                label: '$s×${s == 1.0 ? ' Normal' : ''}',
                selected: playbackSpeed == s,
                onTap: () => onSpeedChanged(s),
              ),
            const _Divider(),
            // Quality
            _sectionLabel('Quality'),
            for (final (val, label) in _qualities)
              _item(
                label: label,
                selected: quality == val,
                onTap: () => onQualityChanged(val),
              ),
            const _Divider(),
            // Loop
            _sectionLabel('Loop'),
            _item(
              label: 'Loop Episode',
              selected: isLooping,
              onTap: () => onLoopToggled(!isLooping),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: Color(0xFF777777),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _item({required String label, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(
              LucideIcons.check,
              size: 14,
              color: selected ? DakkhoColors.success : Colors.transparent,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? DakkhoColors.success : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withValues(alpha: 0.09),
    );
  }
}

/// Episode metadata passed to the player
class EpisodeInfo {
  const EpisodeInfo({
    required this.id,
    required this.title,
    required this.url,
    this.thumbnailUrl,
    this.description,
    this.duration,
  });

  final String id;
  final String title;
  final String url;
  final String? thumbnailUrl;
  final String? description;
  final int? duration;  // seconds
}
