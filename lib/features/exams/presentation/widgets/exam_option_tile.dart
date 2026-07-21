import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

enum ExamOptionVisual { idle, selected, correct, wrong }

class ExamOptionTile extends StatelessWidget {
  const ExamOptionTile({
    required this.option,
    required this.visual,
    super.key,
    this.onTap,
  });

  final ExamOptionEntity option;
  final ExamOptionVisual visual;
  final VoidCallback? onTap;

  Color get _textColor {
    switch (visual) {
      case ExamOptionVisual.selected:
        return AppColors.primary;
      case ExamOptionVisual.correct:
        return AppColors.optionCorrect;
      case ExamOptionVisual.wrong:
        return AppColors.optionWrong;
      case ExamOptionVisual.idle:
        return AppColors.titleDark;
    }
  }

  String get _iconAsset {
    switch (visual) {
      case ExamOptionVisual.selected:
        return 'assets/icons/exams/radio_checked.svg';
      case ExamOptionVisual.correct:
        return 'assets/icons/exams/radio_correct.svg';
      case ExamOptionVisual.wrong:
        return 'assets/icons/exams/radio_wrong.svg';
      case ExamOptionVisual.idle:
        return 'assets/icons/exams/radio_unchecked.svg';
    }
  }

  Color? get _bgColor {
    switch (visual) {
      case ExamOptionVisual.correct:
        return AppColors.optionCorrect.withOpacity(0.10);
      case ExamOptionVisual.wrong:
        return AppColors.optionWrong.withOpacity(0.10);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(8),
          border: (visual == ExamOptionVisual.correct || visual == ExamOptionVisual.wrong)
              ? Border.all(color: _textColor.withOpacity(0.35), width: 1)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                _iconAsset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                textAlign: TextAlign.start,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  height: 20 / 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}