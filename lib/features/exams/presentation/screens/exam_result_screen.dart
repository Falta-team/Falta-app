import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_units_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_option_tile.dart';
import 'package:falta_app/features/exams/presentation/widgets/result_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({
    required this.result,
    super.key,
    this.subjectTitle = 'الرياضيات',
  });

  static const String routeName = '/exam-result';

  final ExamResultEntity result;
  final String subjectTitle;

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  ExamResultFilter _filter = ExamResultFilter.all;

  List<ExamQuestionEntity> get _filtered => widget.result.filtered(_filter);

  ExamOptionVisual _visualFor(ExamQuestionEntity question, String optionId) {
    final option = question.options.firstWhere((o) => o.id == optionId);
    // الإجابة الصحيحة دايماً خضراء
    if (option.isCorrect) return ExamOptionVisual.correct;
    // الإجابة اللي اختارها الطالب وهي خاطئة → حمراء
    if (question.selectedOptionId == optionId) return ExamOptionVisual.wrong;
    return ExamOptionVisual.idle;
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _retake() {
    // ارجع لشاشة ExamUnitsScreen بنفس المادة عشان يختار نفس الاختبار أو غيره
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ExamUnitsScreen(
          subjectTitle: widget.subjectTitle,
        ),
      ),
          (route) => route.settings.name == '/home' || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'النتيجة'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFFEFE),
                    padding: const EdgeInsets.fromLTRB(33, 24, 33, 16),
                    child: Image.asset(
                      'assets/images/exam_result_celebrate.png',
                      height: 187,
                      width: 309,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.score}/${result.total}',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.message,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBright,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ResultFilterChips(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFEFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _filtered.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'لا توجد أسئلة في هذا التصنيف',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          for (var i = 0; i < _filtered.length; i++) ...[
                            if (i > 0) const SizedBox(height: 28),
                            _QuestionReview(
                              index: result.questions
                                  .indexOf(_filtered[i]) +
                                  1,
                              question: _filtered[i],
                              visualFor: _visualFor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              // RTL: الرئيسية يمين، إعادة الأختبار يسار
              child: Row(
                children: [
                  SizedBox(
                    width: 169,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _goHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'الرئيسية',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _retake,
                    child: Text(
                      'إعادة الأختبار',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.titleDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionReview extends StatelessWidget {
  const _QuestionReview({
    required this.index,
    required this.question,
    required this.visualFor,
  });

  final int index;
  final ExamQuestionEntity question;
  final ExamOptionVisual Function(ExamQuestionEntity, String) visualFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$index- ${question.text}',
          textAlign: TextAlign.start,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.titleDark,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 12),
        ...question.options.map(
              (option) => ExamOptionTile(
            option: option,
            visual: visualFor(question, option.id),
          ),
        ),
      ],
    );
  }
}