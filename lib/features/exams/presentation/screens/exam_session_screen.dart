import 'dart:async';

import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:falta_app/features/exams/domain/providers/exams_provider.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_result_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_option_tile.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_timer.dart';
import 'package:falta_app/features/exams/presentation/widgets/question_number_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Live exam session: starts the attempt (`POST /exams/{examId}/start`),
/// runs the countdown timer, lets the student answer, then submits
/// (`POST /exams/{examId}/submit`) when they finish or time runs out.
class ExamSessionScreen extends ConsumerStatefulWidget {
  const ExamSessionScreen({
    required this.examId,
    super.key,
    this.subjectTitle = 'الرياضيات',
    this.timeLimitFallback = 40,
  });

  static const String routeName = '/exam-session';

  final String subjectTitle;
  final String examId;
  /// الوقت المأخوذ من GET /exams — يُستخدم كـ fallback لو الـ start response ما رجّع timeLimit
  final int timeLimitFallback;

  @override
  ConsumerState<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends ConsumerState<ExamSessionScreen> {
  bool _submitting = false;
  String? _attemptId;

  List<ExamQuestionEntity> _questions = const [];
  int _currentIndex = 0;
  /// خريطة questionId → correctOptionId (لو الـ API بيرجعها)
  Map<String, String> _correctAnswers = const {};

  Duration _total = Duration.zero;
  Duration _remaining = Duration.zero;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initFromAttempt({
    required String attemptId,
    required List<ExamQuestionEntity> questions,
    required int timeLimitMinutes,
  }) {
    // Keyed off the attemptId itself (not a one-shot "already initialized"
    // flag) so a *different* attempt — e.g. the fresh one autoDispose
    // fetches when this screen is reopened — always resets the session
    // state instead of being silently ignored.
    if (_attemptId == attemptId) return;
    _attemptId = attemptId;
    _questions = questions;
    // احفظ الإجابات الصحيحة لو موجودة في الـ start response
    _correctAnswers = {
      for (final q in questions)
        for (final o in q.options)
          if (o.isCorrect) q.id: o.id,
    };
    _currentIndex = 0;
    _elapsedSeconds = 0;
    _total = Duration(minutes: timeLimitMinutes > 0 ? timeLimitMinutes : widget.timeLimitFallback);
    _remaining = _total;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _elapsedSeconds += 1;
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
    _autosaveAnswer(optionId);
  }

  /// Fire-and-forget autosave — failures are silent so they never block answering.
  Future<void> _autosaveAnswer(String optionId) async {
    final attemptId = _attemptId;
    if (attemptId == null || attemptId.isEmpty) return;
    final token = SharedPrefController().accessToken;
    if (token.isEmpty) return;
    final questionId = _current.id;
    final elapsed = _elapsedSeconds;
    try {
      await ref.read(examsRepositoryProvider).saveAnswer(
            attemptId: attemptId,
            questionId: questionId,
            answer: optionId,
            timeTakenSeconds: elapsed,
            token: token,
          );
    } catch (_) {
      // Keep UX uninterrupted; final submit still sends all answers.
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _finish() async {
    _timer?.cancel();
    if (_submitting || _attemptId == null) return;
    setState(() => _submitting = true);

    // استخدم Repository مباشرة بدون Riverpod provider
    // عشان نتجنب مشكلة ref.disposed بعد الـ await
    final repository     = ref.read(examsRepositoryProvider);
    final token          = SharedPrefController().accessToken;
    final attemptId      = _attemptId!;
    final elapsedSeconds = _elapsedSeconds;
    final questions      = List.of(_questions);
    final subjectTitle   = widget.subjectTitle;

    try {
      final result = await repository.submitExam(
        examId:           widget.examId,
        attemptId:        attemptId,
        timeTakenSeconds: elapsedSeconds,
        answeredQuestions: questions,
        token:            token,
        correctAnswers:   _correctAnswers,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ExamResultScreen(
            result: result,
            subjectTitle: subjectTitle,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      if (_remaining.inSeconds > 0) _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final attemptAsync = ref.watch(examAttemptProvider(widget.examId));

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: ExamAppBar(title: 'اختبار ${widget.subjectTitle}'),
      body: attemptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: AppColors.titleDark),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(examAttemptProvider(widget.examId)),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (attempt) {
          _initFromAttempt(
            attemptId: attempt.attemptId,
            questions: attempt.questions,
            timeLimitMinutes: attempt.timeLimitMinutes > 0
                ? attempt.timeLimitMinutes
                : widget.timeLimitFallback,
          );

          if (_questions.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أسئلة في هذا الاختبار',
                style: GoogleFonts.cairo(color: AppColors.textSecondary),
              ),
            );
          }

          return Column(
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
                            total: _total,
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
                      // RTL: زر التالي/إنهاء يمين، السابق يسار
                      Row(
                        children: [
                          SizedBox(
                            width: 169,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitting
                                  ? null
                                  : (_currentIndex < _questions.length - 1
                                  ? () => _goTo(_currentIndex + 1)
                                  : _finish),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBright,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                                  : Text(
                                _currentIndex < _questions.length - 1
                                    ? 'التالي'
                                    : 'إنهاء',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_currentIndex > 0)
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
          );
        },
      ),
    );
  }
}