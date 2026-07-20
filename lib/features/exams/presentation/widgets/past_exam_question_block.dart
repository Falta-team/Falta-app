import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// One MCQ item: order + text + RTL 2×2 options + show-answer.
class PastExamQuestionBlock extends StatefulWidget {
  const PastExamQuestionBlock({
    required this.question,
    super.key,
  });

  final PastExamQuestionEntity question;

  @override
  State<PastExamQuestionBlock> createState() => _PastExamQuestionBlockState();
}

class _PastExamQuestionBlockState extends State<PastExamQuestionBlock> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final options = q.options;
    // RTL 2×2: row1 = أ ، ب  |  row2 = ج ، د
    final top = options.take(2).toList();
    final bottom = options.skip(2).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${q.order}ـ ${q.text}',
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.titleDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Container(
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  _showAnswer ? 'إخفاء الإجابة' : 'إظهار الإجابة',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _OptionsRow(options: top, revealCorrect: _showAnswer),
        const SizedBox(height: 8),
        _OptionsRow(options: bottom, revealCorrect: _showAnswer),
      ],
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow({
    required this.options,
    required this.revealCorrect,
  });

  final List<PastExamOptionEntity> options;
  final bool revealCorrect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in options)
          Expanded(
            child: Text(
              '${option.label}) ${option.text}',
              textAlign: TextAlign.start,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: revealCorrect && option.isCorrect
                    ? AppColors.primary
                    : AppColors.titleDark,
              ),
            ),
          ),
      ],
    );
  }
}
