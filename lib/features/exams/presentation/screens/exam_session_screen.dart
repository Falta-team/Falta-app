import 'dart:async';

import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/usecases/get_exam_questions.dart';
import 'package:falta_app/features/exams/domain/usecases/submit_exam.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_result_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_option_tile.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_timer.dart';
import 'package:falta_app/features/exams/presentation/widgets/question_number_strip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamSessionScreen extends StatefulWidget {
  const ExamSessionScreen({
    required this.lessonIds,
    super.key,
    this.subjectTitle = 'الرياضيات',
  });

  static const String routeName = '/exam-session';

  final String subjectTitle;
  final List<String> lessonIds;

  @override
  State<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends State<ExamSessionScreen> {
  static const Duration _totalDuration = Duration(minutes: 40);

  final GetExamQuestions _getExamQuestions =
      const GetExamQuestions(ExamsRepositoryImpl());
  final SubmitExam _submitExam = const SubmitExam();

  bool _loading = true;
  List<ExamQuestionEntity> _questions = const [];
  int _currentIndex = 0;
  Duration _remaining = _totalDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final questions = await _getExamQuestions(lessonIds: widget.lessonIds);
    if (!mounted) return;
    setState(() {
      _questions = questions;
      _loading = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        _finish();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  ExamQuestionEntity get _current => _questions[_currentIndex];

  void _selectOption(String optionId) {
    setState(() {
      _questions = [
        for (var i = 0; i < _questions.length; i++)
          if (i == _currentIndex)
            _questions[i].copyWith(selectedOptionId: optionId)
          else
            _questions[i],
      ];
    });
  }

  void _goTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    setState(() => _currentIndex = index);
  }

  void _finish() {
    _timer?.cancel();
    final result = _submitExam(_questions);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExamResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: ExamAppBar(title: 'اختبار ${widget.subjectTitle}'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      children: [
                        // RTL: start(right)=عداد السؤال، end(left)=المؤقت
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'السؤال ${_currentIndex + 1} من  ${_questions.length}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.titleDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 109,
                                  height: 1,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const Spacer(),
                            ExamTimer(
                              remaining: _remaining,
                              total: _totalDuration,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFEFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _current.text,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.titleDark,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ..._current.options.map(
                                (option) => ExamOptionTile(
                                  option: option,
                                  visual: option.id == _current.selectedOptionId
                                      ? ExamOptionVisual.selected
                                      : ExamOptionVisual.idle,
                                  onTap: () => _selectOption(option.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // RTL: إنهاء يمين، السابق يسار
                        Row(
                          children: [
                            SizedBox(
                              width: 169,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _finish,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBright,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'إنهاء',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _goTo(_currentIndex - 1),
                              child: Text(
                                'السابق',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.titleDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: QuestionNumberStrip(
                      currentIndex: _currentIndex,
                      total: _questions.length,
                      onSelect: _goTo,
                      onPreviousPage: () => _goTo(_currentIndex - 1),
                      onNextPage: () => _goTo(_currentIndex + 1),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
