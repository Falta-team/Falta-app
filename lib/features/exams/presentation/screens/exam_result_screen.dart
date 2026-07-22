import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/ai/data/sources/ai_remote_data_source.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_units_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_option_tile.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_performance_charts.dart';
import 'package:falta_app/features/exams/presentation/widgets/result_filter_chips.dart';
import 'package:falta_app/features/history/data/repositories/history_repository_impl.dart';
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
  bool _analyzing = false;
  AiPerformanceResult? _analysis;
  List<double> _trendPercents = const [];

  List<ExamQuestionEntity> get _filtered => widget.result.filtered(_filter);

  int get _correctCount =>
      widget.result.questions.where((q) => q.isCorrect).length;

  int get _incorrectCount => widget.result.questions
      .where((q) => q.isAnswered && !q.isCorrect)
      .length;

  int get _unansweredCount =>
      widget.result.questions.where((q) => !q.isAnswered).length;

  double get _percent {
    if (widget.result.total <= 0) return 0;
    return (widget.result.score / widget.result.total) * 100;
  }

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
    _loadTrend();
  }

  Future<void> _loadAnalysis() async {
    final attemptId = widget.result.attemptId;
    if (attemptId == null || attemptId.isEmpty) return;
    setState(() => _analyzing = true);
    try {
      final result = await AiRemoteDataSource().analyzePerformance(attemptId);
      if (!mounted) return;
      setState(() {
        _analysis = result;
        _analyzing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _analyzing = false);
    }
  }

  Future<void> _loadTrend() async {
    try {
      final history = await HistoryRepositoryImpl().getRecentPercentages();
      final current = _percent;
      final merged = [...history];
      if (merged.isEmpty || (merged.last - current).abs() > 0.5) {
        merged.add(current);
      } else {
        merged[merged.length - 1] = current;
      }
      if (!mounted) return;
      setState(() {
        _trendPercents = merged.length > 7
            ? merged.sublist(merged.length - 7)
            : merged;
      });
    } catch (_) {}
  }

  ExamOptionVisual _visualFor(ExamQuestionEntity question, String optionId) {
    final option = question.options.firstWhere((o) => o.id == optionId);
    if (option.isCorrect) return ExamOptionVisual.correct;
    if (question.selectedOptionId == optionId) return ExamOptionVisual.wrong;
    return ExamOptionVisual.idle;
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _retake() {
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
    final correct =
        result.questions.isEmpty ? result.score : _correctCount;
    final incorrect = result.questions.isEmpty
        ? (result.total - result.score).clamp(0, result.total)
        : _incorrectCount;
    final unanswered =
        result.questions.isEmpty ? 0 : _unansweredCount;

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
                  const SizedBox(height: 20),
                  ExamPerformanceCharts(
                    correct: correct,
                    incorrect: incorrect,
                    unanswered: unanswered,
                    percent: _percent,
                    trendPercents: _trendPercents,
                  ),
                  if (_analyzing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  if (_analysis != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تحليل الأداء بالذكاء الاصطناعي',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _analysis!.summary,
                              style: GoogleFonts.inter(height: 1.4),
                            ),
                            if (_analysis!.weakTopics.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'نقاط ضعف: ${_analysis!.weakTopics.join('، ')}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (_analysis!.recommendations.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ..._analysis!.recommendations.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• $r',
                                    style: GoogleFonts.inter(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
