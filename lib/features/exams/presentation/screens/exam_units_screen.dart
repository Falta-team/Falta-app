import 'package:falta_app/core/subscription/subscription_gate.dart';
import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/providers/exams_provider.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_session_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_unit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Maps the Arabic subject label shown in the UI to the `subject` slug
/// the real API expects (same values used by `POST /exams` in the
/// Postman collection, e.g. `physics`, `math`).
String _subjectSlug(String arabicTitle) {
  const map = {
    'الرياضيات': 'math',
    'العلوم الحياتية': 'biology',
    'الأحياء': 'biology',
    'الفيزياء': 'physics',
    'الكيمياء': 'chemistry',
    'اللغة العربية': 'arabic',
    'لغة عربيه': 'arabic',
    'اللغة الإنجليزية': 'english',
  };
  return map[arabicTitle.trim()] ?? arabicTitle.trim();
}

/// Lets the student pick one of the ready-made exams for [subjectTitle]
/// (`GET /exams`) and start it. Keeps the original tick-box card design;
/// the underlying API has no "build a custom exam from units/lessons"
/// endpoint, so this now selects a single, complete exam instead.
class ExamUnitsScreen extends ConsumerStatefulWidget {
  const ExamUnitsScreen({
    super.key,
    this.subjectTitle = 'الرياضيات',
    this.embeddedMode = false,
  });

  static const String routeName = '/exam-units';

  final String subjectTitle;
  /// لما تكون embedded في ExamsScreen، نخفي الـ AppBar
  final bool embeddedMode;

  @override
  ConsumerState<ExamUnitsScreen> createState() => _ExamUnitsScreenState();
}

class _ExamUnitsScreenState extends ConsumerState<ExamUnitsScreen> {
  String? _selectedExamId;

  Future<void> _startExam(List<ExamsEntity> exams) async {
    if (_selectedExamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر اختباراً أولاً')),
      );
      return;
    }
    if (!await SubscriptionGate.ensureActive(context)) return;
    if (!mounted) return;
    // ابحث عن الـ exam المختار عشان تمرّر timeLimit الحقيقي
    final idx = exams.indexWhere((e) => e.id == _selectedExamId);
    final timeLimit = idx >= 0 && exams[idx].timeLimit > 0
        ? exams[idx].timeLimit
        : 40;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamSessionScreen(
          subjectTitle: widget.subjectTitle,
          examId: _selectedExamId!,
          timeLimitFallback: timeLimit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = _subjectSlug(widget.subjectTitle);
    final examsAsync = ref.watch(examsBySubjectProvider(subject));

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: widget.embeddedMode ? null : ExamAppBar(title: widget.subjectTitle),
      body: examsAsync.when(
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
                  onPressed: () => ref
                      .read(examsBySubjectProvider(subject).notifier)
                      .refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (exams) => Column(
          children: [
            Expanded(
              child: exams.isEmpty
                  ? Center(
                child: Text(
                  'لا توجد اختبارات متاحة لهذه المادة حالياً',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                itemCount: exams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return ExamUnitCard(
                    exam: exam,
                    isSelected: exam.id == _selectedExamId,
                    onTap: () =>
                        setState(() => _selectedExamId = exam.id),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 40, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _startExam(exams),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'بدأ الاختبار',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}