import 'package:falta_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Progress bar with countdown timer, shown over the video player.
///
/// Layout: [elapsed  ◀──────●────── total]  -remaining
/// `remaining` counts down as the video plays.
class CourseVideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const CourseVideoProgressBar({super.key, required this.controller});

  // "180" seconds → "3:00"
  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        final total = value.duration;
        final elapsed = value.position;
        final remaining = total > elapsed ? total - elapsed : Duration.zero;

        final double progress = total.inMilliseconds > 0
            ? (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(elapsed.inSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    '-${_formatDuration(remaining.inSeconds)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  trackHeight: 3,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.25),
                ),
                child: Slider(
                  value: progress,
                  onChanged: (v) {
                    final seekTo = Duration(
                      milliseconds: (v * total.inMilliseconds).toInt(),
                    );
                    controller.seekTo(seekTo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}