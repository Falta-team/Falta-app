import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/video_entity.dart';
import 'package:falta_app/features/favorites/domain/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'course_video_list_item.dart';

class CourseVideosTab extends ConsumerWidget {
  final AsyncValue<List<VideoEntity>> videosAsync;
  final String? currentVideoId;
  final bool isCurrentVideoPlaying;
  final ValueChanged<VideoEntity> onVideoTap;
  final VoidCallback onRetry;

  const CourseVideosTab({
    super.key,
    required this.videosAsync,
    required this.currentVideoId,
    required this.isCurrentVideoPlaying,
    required this.onVideoTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
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
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد فيديوهات لهذا الكورس بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.textSecondaryLight,
              ),
            ),
          );
        }

        final favNotifier = ref.read(favoritesListProvider.notifier);
        ref.watch(favoritesListProvider);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: videos.length,
          itemBuilder: (context, i) {
            final video = videos[i];
            final isPlaying = currentVideoId == video.id;
            final isSaved = favNotifier.isFavorited('video', video.id);

            return CourseVideoListItem(
              video: video,
              isPlaying: isPlaying,
              isCurrentlyPlayingAudio: isPlaying && isCurrentVideoPlaying,
              isFavorite: isSaved,
              onFavoriteTap: () async {
                try {
                  await favNotifier.toggle(
                    itemType: 'video',
                    itemId: video.id,
                    title: video.title,
                    subtitle: '',
                    image: '',
                    meta: video.courseId,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              onTap: () => onVideoTap(video),
            );
          },
        );
      },
    );
  }
}
