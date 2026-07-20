import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Read-only question block for the history screen.
class HistoryQuestionBlock extends StatelessWidget {
  const HistoryQuestionBlock({
    required this.question,
    super.key,
  });

  final ExamQuestionEntity question;

  ExamOptionVisual _visualFor(String optionId) {
    final option = question.options.firstWhere((o) => o.id == optionId);
    if (option.isCorrect) return ExamOptionVisual.correct;
    if (question.selectedOptionId == optionId && !option.isCorrect) {
      return ExamOptionVisual.wrong;
    }
    return ExamOptionVisual.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          textAlign: TextAlign.start,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in question.options)
          ExamOptionTile(
            option: option,
            visual: _visualFor(option.id),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
