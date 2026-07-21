import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card representing a single ready-made exam from `GET /exams`.
///
/// Keeps the original tick-box visual design (previously used for a
/// unit/lesson picker that had no backing endpoint); tapping the tick or
/// the card selects this exam as the one to start.
class ExamUnitCard extends StatelessWidget {
  const ExamUnitCard({
    required this.exam,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ExamsEntity exam;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          children: [
            _TickBox(checked: isSelected, onTap: onTap),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: exam.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.titleDark,
                        letterSpacing: 0.08,
                      ),
                    ),
                    TextSpan(
                      text: '  ${exam.year} · ${exam.totalQuestions} سؤال · '
                          '${exam.timeLimit} د',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.titleDark.withValues(alpha: 0.7),
                        letterSpacing: 0.06,
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

class _TickBox extends StatelessWidget {
  const _TickBox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          checked
              ? 'assets/icons/exams/tick_checked.svg'
              : 'assets/icons/exams/tick_unchecked.svg',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
