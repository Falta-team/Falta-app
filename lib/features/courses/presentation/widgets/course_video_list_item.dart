import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single row in the "الفيديوهات" (videos) tab list.
class CourseVideoListItem extends StatelessWidget {
  final VideoEntity video;
  final bool isPlaying;
  final bool isCurrentlyPlayingAudio;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const CourseVideoListItem({
    super.key,
    required this.video,
    required this.isPlaying,
    required this.isCurrentlyPlayingAudio,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                isPlaying && isCurrentlyPlayingAudio
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 22,
              ),
            ),
            14.ws,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPlaying ? AppColors.primary : AppColors.textDark,
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
            if (onFavoriteTap != null)
              IconButton(
                onPressed: onFavoriteTap,
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color:
                      isFavorite ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
