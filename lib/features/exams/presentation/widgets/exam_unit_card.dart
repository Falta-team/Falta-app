import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exam_unit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamUnitCard extends StatelessWidget {
  const ExamUnitCard({
    required this.unit,
    required this.onToggleExpand,
    required this.onToggleUnit,
    required this.onToggleLesson,
    super.key,
  });

  final ExamUnitEntity unit;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleUnit;
  final ValueChanged<String> onToggleLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // RTL: start=right → tick, title, then chevron at end (left)
          Row(
            children: [
              _TickBox(checked: unit.isSelected, onTap: onToggleUnit),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onToggleExpand,
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: unit.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.titleDark,
                            letterSpacing: 0.08,
                          ),
                        ),
                        TextSpan(
                          text: ' ${unit.subtitle}',
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
              ),
              GestureDetector(
                onTap: onToggleExpand,
                child: Icon(
                  unit.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: AppColors.titleDark,
                ),
              ),
            ],
          ),
          if (unit.isExpanded) ...[
            const SizedBox(height: 12),
            ...unit.lessons.map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    _TickBox(
                      checked: lesson.isSelected,
                      onTap: () => onToggleLesson(lesson.id),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.title,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleDark,
                          letterSpacing: 0.07,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
