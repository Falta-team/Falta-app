import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// List card for a favorite course lesson ("الكورسات" tab).
class FavoriteLessonCard extends StatelessWidget {
  const FavoriteLessonCard({
    required this.lesson,
    super.key,
    this.onTap,
    this.onRemove,
  });

  final FavoriteLessonEntity lesson;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDFD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Texts (start side in RTL) ───────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.lessonTitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.subject,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      color: const Color(0xCC000000),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onRemove,
                        child: SvgPicture.asset(
                          'assets/icons/profile/ic_bookmark.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        lesson.teacherName,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Video thumbnail (end side in RTL) ───────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 117,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      '${lesson.image}.png'.image_,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFFD9D9D9)),
                    ),
                    Container(color: const Color(0x78000000)),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/profile/ic_video_play.svg',
                        width: 27,
                        height: 27,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
