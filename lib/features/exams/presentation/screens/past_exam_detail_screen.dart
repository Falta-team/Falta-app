import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/data/repositories/past_exams_repository_impl.dart';
import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:falta_app/features/exams/domain/usecases/get_past_exam_paper.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/past_exam_question_block.dart';
import 'package:falta_app/features/exams/presentation/widgets/section_page_strip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// تفاصيل اختبار سنة — أقسام مرتبة + أسئلة مرتبة + تنقّل بالصفحات.
class PastExamDetailScreen extends StatefulWidget {
  const PastExamDetailScreen({
    required this.paperId,
    super.key,
  });

  static const String routeName = '/past-exam-detail';

  final String paperId;

  @override
  State<PastExamDetailScreen> createState() => _PastExamDetailScreenState();
}

class _PastExamDetailScreenState extends State<PastExamDetailScreen> {
  final GetPastExamPaper _getPaper =
      const GetPastExamPaper(PastExamsRepositoryImpl());

  bool _loading = true;
  PastExamPaperEntity? _paper;
  int _sectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final paper = await _getPaper(widget.paperId);
    if (!mounted) return;
    setState(() {
      _paper = paper;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paper = _paper;
    final sections = paper?.sortedSections ?? const <PastExamSectionEntity>[];
    final section = sections.isEmpty ? null : sections[_sectionIndex];

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: ExamAppBar(
        title: paper == null
            ? '...'
            : 'اختبار سنة  ${paper.yearLabel}',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : paper == null || section == null
              ? const Center(child: Text('لم يتم العثور على الاختبار'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                section.title,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.titleDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                section.instruction,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.titleDark
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...section.sortedQuestions.map(
                                (q) => Column(
                                  children: [
                                    const Divider(height: 24),
                                    PastExamQuestionBlock(question: q),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (sections.length > 1)
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: SectionPageStrip(
                            currentIndex: _sectionIndex,
                            total: sections.length,
                            onSelect: (i) =>
                                setState(() => _sectionIndex = i),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
