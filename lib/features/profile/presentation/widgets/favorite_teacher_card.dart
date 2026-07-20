import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/profile/domain/entities/favorite_entities.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Grid card for a favorite teacher ("المدرسين" tab).
class FavoriteTeacherCard extends StatelessWidget {
  const FavoriteTeacherCard({
    required this.teacher,
    super.key,
    this.onTap,
    this.onRemove,
  });

  final FavoriteTeacherEntity teacher;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x17000000)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo with dark overlay ─────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: SizedBox(
                height: 91,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      '${teacher.image}.png'.image_,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.person,
                          size: 44,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(color: const Color(0x59000000)),
                  ],
                ),
              ),
            ),

            // ── Name + rating ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      teacher.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Image.asset('rating_star.png'.icon_, height: 15, width: 15),
                  const SizedBox(width: 2),
                  Text(
                    teacher.rating.toStringAsFixed(
                      teacher.rating.truncateToDouble() == teacher.rating
                          ? 0
                          : 1,
                    ),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bio ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                teacher.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 8,
                  height: 1.5,
                  color: const Color(0x80000000),
                ),
              ),
            ),

            const Spacer(),

            // ── Price + bookmark ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${teacher.price} شيكل',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: SvgPicture.asset(
                      'assets/icons/profile/ic_bookmark.svg',
                      width: 17,
                      height: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
