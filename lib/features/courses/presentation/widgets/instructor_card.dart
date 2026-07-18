import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/courses/domain/entities/instructor_entity.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card used in the Instructor List screen.
///
/// Shows the teacher's photo inside a grey rounded square, their name,
/// a sub-headline (subject / grade), and a price tag with a green icon.
class InstructorCard extends StatelessWidget {
  final Map<String, dynamic> instructor;
  late String name;

  final VoidCallback onSave;
  final VoidCallback onTap;

   InstructorCard({
    required this.instructor,
    required this.onSave,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool saved = instructor['saved'] as bool;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Teacher photo ────────────────────────────────────────────
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/${instructor['image']}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.person,
                        size: 52, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating + name row
                  Row(
                    children: [
                      Text(
                        instructor['fullName'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Text(
                        '${instructor['rating']}',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: AppColors.primary,
                        ),
                      ),
                      2.ws,

                       Image.asset('rating_star.png'.icon_,height: 16,width: 16,),


                    ],
                  ),
                  4.hs,

                  3.hs,
                  Text(
                    instructor['desc'] as String,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.textSecondaryLight,
                      fontFamily: 'Cairo',
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Price + Bookmark ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${instructor['price']} شيكل',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  GestureDetector(
                    onTap: onSave,
                    child: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primary,
                      size: 22,
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