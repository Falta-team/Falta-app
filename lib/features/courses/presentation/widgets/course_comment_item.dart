import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/comment_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single row in the "التعليقات" (comments) tab list.
class CourseCommentItem extends StatelessWidget {
  final CommentEntity comment;

  const CourseCommentItem({super.key, required this.comment});

  // "قبل 5 دقائق" / "قبل 3 ساعات" / "قبل يومين" ...
  static String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final c = comment;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            backgroundImage:
            c.userAvatarUrl.isNotEmpty ? NetworkImage(c.userAvatarUrl) : null,
            child: c.userAvatarUrl.isEmpty
                ? Text(
              c.userName.isNotEmpty ? c.userName.substring(0, 1) : '؟',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
              ),
            )
                : null,
          ),
          const SizedBox(width: 10),
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
                const SizedBox(height: 4),
                Text(
                  c.body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_outlined,
                      size: 15,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${c.likesCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    if (c.createdAt != null) ...[
                      const SizedBox(width: 16),
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
                const SizedBox(height: 8),
                const Divider(color: AppColors.border, height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}