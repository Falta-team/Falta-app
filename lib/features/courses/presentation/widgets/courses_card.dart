import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const CoursesCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (course['progress'] as double?) ?? 0.0;
    final bool hasProgress = progress > 0;
    final bool isPaid = (course['isPaid'] as bool?) ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Subject icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAppColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    'assets/images/${course['image']}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                12.ws,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            course['subject'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const Spacer(),
                          // Paid / Free badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFE8F5E2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPaid ? '💳 مدفوع' : '✓ مجاني',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                                color: isPaid
                                    ? AppColors.warning
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.hs,
                      Text(
                        course['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      4.hs,
                      Text(
                        course['teacher'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            10.hs,

            // Meta row
            Row(
              children: [
                const Icon(Icons.play_circle_outline,
                    size: 13, color: AppColors.textSecondaryLight),
                4.ws,
                Text('${course['lessons']} درس',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontFamily: 'Cairo')),
                12.ws,
                const Icon(Icons.access_time,
                    size: 13, color: AppColors.textSecondaryLight),
                4.ws,
                Text('${course['hours']} ساعة',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontFamily: 'Cairo')),
                12.ws,
                const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                4.ws,
                Text('${course['rating']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontFamily: 'Cairo')),
              ],
            ),

            // Progress bar
            if (hasProgress) ...[
              10.hs,
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  8.ws,
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}