import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/courses/domain/providers/courses_provider.dart';
import 'package:falta_app/features/courses/presentation/widgets/course_comments_tab.dart';
import 'package:falta_app/features/courses/presentation/widgets/course_fullscreen_player.dart';
import 'package:falta_app/features/courses/presentation/widgets/course_video_header.dart';
import 'package:falta_app/features/courses/presentation/widgets/course_videos_tab.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/video/video_cache_manager.dart';
import 'package:falta_app/utils/video/video_player_controller_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  static const String routeName = '/course-detail';

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  VideoEntity? _currentVideo;
  bool _videoLoading = false;
  Object? _videoError;
  List<VideoEntity> _videos = const [];
  bool _autoplayedFirstVideo = false;
  bool _advancingToNext = false;

  // ── Playback speed (0.5x / 1.0x / 1.5x / 2.0x) ───────────────────────────
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 1.0, 1.5, 2.0];
  // ── Video quality ─────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailsProvider(widget.courseId));
    final videosAsync = ref.watch(courseVideosProvider(widget.courseId));
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
      return CourseFullScreenPlayer(
        controller: _videoController,
        playbackSpeed: _playbackSpeed,
        speedOptions: _speedOptions,
        onSpeedSelected: _setPlaybackSpeed,
        onExitFullScreen: _toggleFullScreen,
        onTogglePlayPause: _togglePlayPause,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: courseAsync.when(
          loading: () =>
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              Center(
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
                        onPressed: () =>
                            ref.invalidate(
                                courseDetailsProvider(widget.courseId)),
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
          data: (course) => _buildContent(context, course, videosAsync),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context,
      CoursesEntity course,
      AsyncValue<List<VideoEntity>> videosAsync,) {
    return Column(
      children: [
        Stack(
          children: [
            CourseVideoHeader(
              course: course,
              controller: _videoController,
              videoLoading: _videoLoading,
              videoError: _videoError,
              selectedQuality: _selectedQuality,
              qualityOptions: _qualityOptions,
              onQualitySelected: _setQuality,
              playbackSpeed: _playbackSpeed,
              speedOptions: _speedOptions,
              onSpeedSelected: _setPlaybackSpeed,
              onToggleFullScreen: _toggleFullScreen,
              onTogglePlayPause: _togglePlayPause,
              onTapThumbnail: () => _onTapThumbnail(videosAsync),
            ),
            Positioned(
              top: MediaQuery
                  .of(context)
                  .padding
                  .top + 10,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_filled_rounded,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          4.ws,
                          Text(
                            '${course.videoCount} فيديو',
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
                            _formatDuration(course.totalDuration),
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
                      CourseVideosTab(
                        videosAsync: videosAsync,
                        currentVideoId: _currentVideo?.id,
                        isCurrentVideoPlaying:
                        _videoController?.value.isPlaying ?? false,
                        onVideoTap: _playVideo,
                        onRetry: () =>
                            ref.invalidate(courseVideosProvider(widget
                                .courseId)),
                      ),
                      CourseCommentsTab(
                        videoId: _currentVideo?.id,
                        commentController: _commentController,
                        onSubmit: _submitComment,
                      ),
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
    if (_currentVideo?.id == video.id && _videoController != null) {
      _togglePlayPause();
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

    // ✅ Uses VideoControllerFactory — returns cached file if available,
    // falls back to network and caches in background for next time.
    // Per graduation report NFR1.1: video start < 3 s on 4G.
    final controller = await VideoControllerFactory.create(video.videoUrl);

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
      _preloadNextVideo(video);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _videoLoading = false;
        _videoError = e;
      });
    }
  }

  void _togglePlayPause() {
    final controller = _videoController;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void _onVideoTick() {
    if (!mounted) return;

    final controller = _videoController;
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
      _advancingToNext = false;
      return;
    }

    await _playVideo(_videos[currentIndex + 1]);
  }

  /// Preloads the next video into cache in the background.
  /// Called right after a video starts playing so the next video is
  /// ready instantly when the user advances (or auto-advance fires).
  /// Per graduation report §5.4.2: "Recently viewed content cached."
  void _preloadNextVideo(VideoEntity currentVideo) {
    final currentIndex = _videos.indexWhere((v) => v.id == currentVideo.id);
    if (currentIndex == -1 || currentIndex >= _videos.length - 1) return;

    final nextUrl = _videos[currentIndex + 1].videoUrl;
    if (nextUrl.isEmpty) return;

    // Fire and forget — caches the file without blocking the UI
    VideoCacheManager().getSingleFile(nextUrl).catchError((_) {});
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(speed);
    }
  }

  void _setQuality(String quality) {
    setState(() => _selectedQuality = quality);
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

  void _onTapThumbnail(AsyncValue<List<VideoEntity>> videosAsync) {
    if (_videoLoading) return;
    final videos = videosAsync.asData?.value;
    if (videos != null && videos.isNotEmpty) {
      _playVideo(videos.first);
    }
  }

  // "180" seconds → "3:00"
  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}