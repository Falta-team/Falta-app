import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'course_speed_button.dart';
import 'course_video_progress_bar.dart';

/// Landscape fullscreen video player, shown when the user rotates the
/// player into fullscreen mode.
class CourseFullScreenPlayer extends StatelessWidget {
  final VideoPlayerController? controller;
  final double playbackSpeed;
  final List<double> speedOptions;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onExitFullScreen;
  final VoidCallback onTogglePlayPause;

  const CourseFullScreenPlayer({
    super.key,
    required this.controller,
    required this.playbackSpeed,
    required this.speedOptions,
    required this.onSpeedSelected,
    required this.onExitFullScreen,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final isReady = controller != null && controller.value.isInitialized;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isReady)
              GestureDetector(
                onTap: onTogglePlayPause,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else
              const CircularProgressIndicator(color: AppColors.primary),

            if (isReady && !controller.value.isPlaying)
              const Icon(
                Icons.play_circle_filled,
                size: 64,
                color: Colors.white,
              ),

            Positioned(
              top: 8,
              right: 12,
              child: IconButton(
                onPressed: onExitFullScreen,
                icon: const Icon(
                  Icons.fullscreen_exit,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            Positioned(
              top: 8,
              left: 12,
              child: CourseSpeedButton(
                playbackSpeed: playbackSpeed,
                options: speedOptions,
                color: Colors.white,
                onSelected: onSpeedSelected,
              ),
            ),

            if (isReady)
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
}