import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/providers/courses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'course_comment_item.dart';

/// "التعليقات" tab. Comments are per-video (`GET/POST /videos/{id}/comments`),
/// so a video must already be selected — pass `videoId == null` to show the
/// "pick a video first" placeholder instead.
class CourseCommentsTab extends ConsumerWidget {
  final String? videoId;
  final TextEditingController commentController;
  final ValueChanged<String> onSubmit;

  const CourseCommentsTab({
    super.key,
    required this.videoId,
    required this.commentController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoId = this.videoId;
    if (videoId == null) {
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

    final commentsAsync = ref.watch(videoCommentsProvider(videoId));

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: commentsAsync.when(
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
                  onPressed: () => ref.invalidate(videoCommentsProvider(videoId)),
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
        data: (comments) => comments.isEmpty
            ? const Center(
          child: Text(
            'لا توجد تعليقات بعد، كن أول من يعلق',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondaryLight,
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: comments.length,
          itemBuilder: (context, i) =>
              CourseCommentItem(comment: comments[i]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
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
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () => onSubmit(videoId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}