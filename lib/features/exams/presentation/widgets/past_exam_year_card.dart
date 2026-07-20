import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PastExamYearCard extends StatelessWidget {
  const PastExamYearCard({
    required this.paper,
    required this.onTap,
    super.key,
  });

  final PastExamPaperEntity paper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 80,
        padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        // RTL: image on start(right), text after it.
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                paper.imageAsset,
                width: 55,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 55,
                  height: 56,
                  color: const Color(0xFFD9D9D9),
                  child: const Icon(Icons.assignment, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'اختبار سنة ${paper.yearLabel}',
                textAlign: TextAlign.start,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.titleDark,
                  height: 20 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
