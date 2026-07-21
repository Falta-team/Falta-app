import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'course_quality_button.dart';
import 'course_speed_button.dart';
import 'course_video_progress_bar.dart';

/// Header shown at the top of the course detail screen: the real video
/// player once a video is loaded, or a fallback thumbnail while loading /
/// on error / before any video has been selected.
class CourseVideoHeader extends StatelessWidget {
  final CoursesEntity course;
  final VideoPlayerController? controller;
  final bool videoLoading;
  final Object? videoError;

  final String selectedQuality;
  final List<String> qualityOptions;
  final ValueChanged<String> onQualitySelected;

  final double playbackSpeed;
  final List<double> speedOptions;
  final ValueChanged<double> onSpeedSelected;

  final VoidCallback onToggleFullScreen;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onTapThumbnail;

  const CourseVideoHeader({
    super.key,
    required this.course,
    required this.controller,
    required this.videoLoading,
    required this.videoError,
    required this.selectedQuality,
    required this.qualityOptions,
    required this.onQualitySelected,
    required this.playbackSpeed,
    required this.speedOptions,
    required this.onSpeedSelected,
    required this.onToggleFullScreen,
    required this.onTogglePlayPause,
    required this.onTapThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    // ✅ A video is loaded and ready → show the real player.
    if (controller != null && controller.value.isInitialized) {
      return GestureDetector(
        onTap: onTogglePlayPause,
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
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Row(
                  children: [
                    CourseQualityButton(
                      selectedQuality: selectedQuality,
                      options: qualityOptions,
                      color: Colors.white,
                      onSelected: onQualitySelected,
                    ),
                    8.ws,
                    CourseSpeedButton(
                      playbackSpeed: playbackSpeed,
                      options: speedOptions,
                      color: Colors.white,
                      onSelected: onSpeedSelected,
                    ),
                    8.ws,
                    GestureDetector(
                      onTap: onToggleFullScreen,
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
                child: CourseVideoProgressBar(controller: controller),
              ),
            ],
          ),
        ),
      );
    }

    // ── Fallback thumbnail (loading / error / nothing selected yet) ──────
    return GestureDetector(
      onTap: videoLoading ? null : onTapThumbnail,
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
              child: videoLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(
                videoError != null
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
}