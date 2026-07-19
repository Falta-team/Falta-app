import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/courses/domain/providers/courses_provider.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  /// Real course id, used to fetch details via [courseDetailsProvider].
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  static const String routeName = '/course-detail';

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // The videos list is real, fetched via `courseVideosProvider(courseId)`
  // → `GET /courses/{id}/videos`. Comments are also real, fetched per-video
  // via `videoCommentsProvider(videoId)` → `GET /videos/{id}/comments`
  // (see `_buildCommentsTab`).

  VideoPlayerController? _videoController;
  VideoEntity? _currentVideo;
  bool _videoLoading = false;
  Object? _videoError;

  /// Full videos list for the course, kept in sync from
  /// `courseVideosProvider` so `_playNextVideo` can find what comes after
  /// the video that just finished (auto-advance).
  List<VideoEntity> _videos = const [];

  /// True once we've auto-played the first video for this screen — avoids
  /// re-triggering autoplay every time the provider rebuilds.
  bool _autoplayedFirstVideo = false;

  /// Guards `_onVideoTick` so a finished video only triggers one
  /// auto-advance instead of firing repeatedly while paused at the end.
  bool _advancingToNext = false;

  // ── Playback speed (0.5x / 1.0x / 1.5x / 2.0x) ───────────────────────────
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 1.0, 1.5, 2.0];

  // ── Video quality ─────────────────────────────────────────────────────
  // NOTE: the real API (`VideoEntity.videoUrl`) only exposes a single,
  // direct `.mp4` URL per video — there's no separate URL per resolution.
  // Quality switching is mocked here (all options play the same source);
  // wire this up to real per-resolution URLs once the API exposes them.
  String _selectedQuality = '720p';
  static const List<String> _qualityOptions = ['360p', '480p', '720p'];

  // ── Fullscreen (landscape) mode ──────────────────────────────────────
  bool _isFullScreen = false;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    _commentController.dispose();
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  Future<void> _toggleFullScreen() async {
    final goingFullScreen = !_isFullScreen;
    setState(() => _isFullScreen = goingFullScreen);

    if (goingFullScreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _playVideo(VideoEntity video) async {
    // Same video tapped again → just toggle play/pause instead of
    // re-initializing the controller from scratch.
    if (_currentVideo?.id == video.id && _videoController != null) {
      final controller = _videoController!;
      setState(() {
        controller.value.isPlaying ? controller.pause() : controller.play();
      });
      return;
    }

    final oldController = _videoController;
    oldController?.removeListener(_onVideoTick);

    setState(() {
      _currentVideo = video;
      _videoController = null;
      _videoLoading = true;
      _videoError = null;
      _advancingToNext = false;
    });

    await oldController?.dispose();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(video.videoUrl),
    );

    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      await controller.setPlaybackSpeed(_playbackSpeed);
      controller.addListener(_onVideoTick);
      setState(() {
        _videoController = controller;
        _videoLoading = false;
      });
      controller.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _videoLoading = false;
        _videoError = e;
      });
    }
  }

  void _onVideoTick() {
    if (!mounted) return;

    final controller = _videoController;
    // Auto-advance: current video reached its end (and playback stopped) →
    // automatically play the next video in the course, in sequence order.
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying &&
        controller.value.duration.inMilliseconds > 0 &&
        controller.value.position >= controller.value.duration &&
        !_advancingToNext) {
      _advancingToNext = true;
      _playNextVideo();
      return;
    }

    setState(() {});
  }

  Future<void> _playNextVideo() async {
    final current = _currentVideo;
    if (current == null || _videos.isEmpty) {
      _advancingToNext = false;
      return;
    }

    final currentIndex = _videos.indexWhere((v) => v.id == current.id);
    if (currentIndex == -1 || currentIndex == _videos.length - 1) {
      // Last video in the course — nothing left to auto-advance to.
      _advancingToNext = false;
      return;
    }

    await _playVideo(_videos[currentIndex + 1]);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(speed);
    }
  }

  void _setQuality(String quality) {
    // Mocked: the API only exposes one URL per video, so switching quality
    // doesn't change the actual stream today — see the NOTE on
    // `_selectedQuality` above.
    setState(() => _selectedQuality = quality);
  }

  Widget _buildQualityButton({required Color color}) {
    return PopupMenuButton<String>(
      initialValue: _selectedQuality,
      onSelected: _setQuality,
      color: Colors.black87,
      itemBuilder: (context) => _qualityOptions
          .map((q) => PopupMenuItem(
        value: q,
        child: Text(
          q,
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
      ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hd_outlined, color: color, size: 20),
          2.ws,
          Text(
            _selectedQuality,
            style: TextStyle(color: color, fontSize: 11, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton({required Color color}) {
    return PopupMenuButton<double>(
      initialValue: _playbackSpeed,
      onSelected: _setPlaybackSpeed,
      color: Colors.black87,
      itemBuilder: (context) => _speedOptions
          .map((s) => PopupMenuItem(
        value: s,
        child: Text(
          '${s}x',
          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
      ))
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, color: color, size: 20),
          2.ws,
          Text(
            '${_playbackSpeed}x',
            style: TextStyle(color: color, fontSize: 11, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    final videosAsync = ref.watch(courseVideosProvider(widget.courseId));

    // Keep `_videos` in sync (used by auto-advance) and autoplay the first
    // video the moment the list loads successfully.
    ref.listen<AsyncValue<List<VideoEntity>>>(
      courseVideosProvider(widget.courseId),
          (previous, next) {
        final videos = next.asData?.value;
        if (videos == null) return;
        _videos = videos;
        if (!_autoplayedFirstVideo && videos.isNotEmpty) {
          _autoplayedFirstVideo = true;
          _playVideo(videos.first);
        }
      },
    );

    if (_isFullScreen) {
      return _buildFullScreenPlayer();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: courseAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                  12.hs,
                  TextButton(
                    onPressed: () => ref.invalidate(
                      courseDetailsProvider(widget.courseId),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (course) =>
              _buildContent(context, course, videosAsync),
        ),
      ),
    );
  }

  // ── Fullscreen (landscape) player ────────────────────────────────────────
  Widget _buildFullScreenPlayer() {
    final controller = _videoController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (controller != null && controller.value.isInitialized)
              GestureDetector(
                onTap: () => setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                }),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(color: AppColors.primary),

            if (controller != null &&
                controller.value.isInitialized &&
                !controller.value.isPlaying)
              const Icon(
                Icons.play_circle_filled,
                size: 64,
                color: Colors.white,
              ),

            // Exit fullscreen
            Positioned(
              top: 8,
              right: 12,
              child: IconButton(
                onPressed: _toggleFullScreen,
                icon: const Icon(Icons.fullscreen_exit,
                    color: Colors.white, size: 30),
              ),
            ),

            // Speed control
            Positioned(
              top: 8,
              left: 12,
              child: _buildSpeedButton(color: Colors.white),
            ),

            // Progress bar
            if (controller != null && controller.value.isInitialized)
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Video header (real player when a video is selected) ─────────────────
  Widget _buildVideoHeader(
      CoursesEntity course,
      AsyncValue<List<VideoEntity>> videosAsync,
      ) {
    final controller = _videoController;

    // ✅ A video is loaded and ready → show the real player.
    if (controller != null && controller.value.isInitialized) {
      return GestureDetector(
        onTap: () => setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        }),
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
              if (!controller.value.isPlaying)
                const Icon(
                  Icons.play_circle_filled,
                  size: 56,
                  color: Colors.white,
                ),

              // Quality / speed / fullscreen controls
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: Row(
                  children: [
                    _buildQualityButton(color: Colors.white),
                    8.ws,
                    _buildSpeedButton(color: Colors.white),
                    8.ws,
                    GestureDetector(
                      onTap: _toggleFullScreen,
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Fallback thumbnail (loading / error / nothing selected yet) ──────
    return GestureDetector(
      onTap: () {
        if (_videoLoading) return;
        // Change this line:
        final videos = videosAsync.asData?.value;
        print(videos);
        if (videos != null && videos.isNotEmpty) {
          _playVideo(videos.first);
        }
      },
      child: Stack(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.asset(
              'assets/images/${course.image.isNotEmpty ? course.image : 'math'}.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A1A2E)),
            ),
          ),
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x99000000)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: _videoLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(
                _videoError != null
                    ? Icons.error_outline
                    : Icons.play_circle_filled,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      CoursesEntity course,
      AsyncValue<List<VideoEntity>> videosAsync,
      ) {
    return Column(
      children: [
        // ── Dark Video Header ─────────────────────────────────────────
        Stack(
          children: [
            _buildVideoHeader(course, videosAsync),

            // Back arrow (top left in RTL = top right visually)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),

        // ── White Bottom Sheet ────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title row + Bookmark ───────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                          12.ws,
                          const Icon(
                            Icons.bookmark,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ],
                      ),

                      12.hs,

                      // ── Teacher ────────────────────────────────────
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          6.ws,
                          Text(
                            course.instructorName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Cairo',
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      10.hs,

                      // ── Videos count ────────────────────────────────
                      // NOTE: CoursesEntity only exposes `lessonsCount`;
                      // there is no confirmed duration/hours/minutes
                      // field from the API, so that part of the original
                      // mock UI is left blank rather than fabricated.
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_filled_rounded,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          4.ws,
                          Text(
                            '${course.lessonsCount} فيديو',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          36.ws,
                          const Icon(
                            Icons.access_time_filled,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          4.ws,
                          Text(
                            '${course.lessonsCount} س',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),

                      14.hs,

                      // ── About section ──────────────────────────────
                      Text(
                        'نبذة عن الكورس',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      6.hs,
                      Text(
                        course.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),

                14.hs,

                // ── Tabs ──────────────────────────────────────────────
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondaryLight,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'الفيديوهات'),
                    Tab(text: 'التعليقات'),
                  ],
                ),

                // ── Tab content ───────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVideosTab(videosAsync),
                      _buildCommentsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Videos Tab ─────────────────────────────────────────────────────────────
  Widget _buildVideosTab(AsyncValue<List<VideoEntity>> videosAsync) {
    return videosAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textSecondaryLight,
                ),
              ),
              12.hs,
              TextButton(
                onPressed: () => ref.invalidate(
                  courseVideosProvider(widget.courseId),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد فيديوهات لهذا الكورس بعد',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: videos.length,
          itemBuilder: (context, i) {
            final video = videos[i];
            final isPlaying = _currentVideo?.id == video.id;

            return InkWell(
              onTap: () => _playVideo(video),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Green play button (highlighted while active)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying && (_videoController?.value.isPlaying ?? false)
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    14.ws,

                    // Lesson info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isPlaying
                                  ? AppColors.primary
                                  : AppColors.textDark,
                            ),
                          ),
                          4.hs,
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              4.ws,
                              Text(
                                _formatDuration(video.duration),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // "180" seconds → "3:00"
  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ── Comments Tab ────────────────────────────────────────────────────────────
  // Comments are per-video (`GET/POST /videos/{id}/comments`), so this tab
  // needs a video selected first — it watches `videoCommentsProvider` keyed
  // by `_currentVideo!.id`.
  Widget _buildCommentsTab() {
    final video = _currentVideo;
    if (video == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'اختر فيديو من قائمة الفيديوهات لعرض التعليقات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    final commentsAsync = ref.watch(videoCommentsProvider(video.id));

    return Column(
      children: [
        Expanded(
          child: commentsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    12.hs,
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(videoCommentsProvider(video.id)),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                            fontFamily: 'Cairo', color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد تعليقات بعد، كن أول من يعلق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: comments.length,
                itemBuilder: (context, i) {
                  final c = comments[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          backgroundImage: c.userAvatarUrl.isNotEmpty
                              ? NetworkImage(c.userAvatarUrl)
                              : null,
                          child: c.userAvatarUrl.isEmpty
                              ? Text(
                            c.userName.isNotEmpty
                                ? c.userName.substring(0, 1)
                                : '؟',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                            ),
                          )
                              : null,
                        ),
                        10.ws,

                        // Comment body
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.userName,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              4.hs,
                              Text(
                                c.body,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                  height: 1.5,
                                ),
                              ),
                              8.hs,

                              // Likes + relative time
                              Row(
                                children: [
                                  const Icon(
                                    Icons.thumb_up_outlined,
                                    size: 15,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  4.ws,
                                  Text(
                                    '${c.likesCount}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondaryLight,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  if (c.createdAt != null) ...[
                                    16.ws,
                                    Text(
                                      _formatRelativeTime(c.createdAt!),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondaryLight,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Divider
                              8.hs,
                              const Divider(color: AppColors.border, height: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // ── Composer ──────────────────────────────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                8.ws,
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _submitComment(video.id),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitComment(String videoId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      await ref.read(videoCommentsProvider(videoId).notifier).addComment(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }
  }

  // "قبل 5 دقائق" / "قبل 3 ساعات" / "قبل يومين" ...
  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }
}
