import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/data/repositories/past_exams_repository_impl.dart';
import 'package:falta_app/features/exams/domain/entities/past_exam_entities.dart';
import 'package:falta_app/features/exams/domain/usecases/get_past_exam_subjects.dart';
import 'package:falta_app/features/exams/presentation/screens/past_exam_detail_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/past_exam_year_card.dart';
import 'package:falta_app/utils/extensions/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PastExamsLayout { accordion, grid }

/// أرشيف اختبارات السنوات السابقة — قائمة أكورديون أو شبكة حسب Figma.
class PastExamsArchiveScreen extends StatefulWidget {
  const PastExamsArchiveScreen({super.key});

  static const String routeName = '/past-exams';

  @override
  State<PastExamsArchiveScreen> createState() => _PastExamsArchiveScreenState();
}

class _PastExamsArchiveScreenState extends State<PastExamsArchiveScreen> {
  final GetPastExamSubjects _getSubjects =
      const GetPastExamSubjects(PastExamsRepositoryImpl());

  bool _loading = true;
  List<PastExamSubjectEntity> _subjects = const [];
  PastExamsLayout _layout = PastExamsLayout.accordion;
  int _selectedChip = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final subjects = await _getSubjects();
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      _loading = false;
    });
  }

  void _toggleSubject(String id) {
    setState(() {
      _subjects = _subjects
          .map(
            (s) => s.id == id
                ? s.copyWith(isExpanded: !s.isExpanded)
                : s.copyWith(isExpanded: false),
          )
          .toList();
    });
  }

  void _openPaper(PastExamPaperEntity paper) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PastExamDetailScreen(paperId: paper.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              layout: _layout,
              onToggleLayout: () {
                setState(() {
                  _layout = _layout == PastExamsLayout.accordion
                      ? PastExamsLayout.grid
                      : PastExamsLayout.accordion;
                });
              },
            ),
            const Divider(height: 1, color: Color(0xFFEAEAEA)),
            if (_layout == PastExamsLayout.grid) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = i == _selectedChip;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedChip = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          _subjects[i].name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? AppColors.white
                                : AppColors.titleDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
            ],
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _layout == PastExamsLayout.accordion
                      ? _AccordionBody(
                          subjects: _subjects,
                          onToggle: _toggleSubject,
                          onOpenPaper: _openPaper,
                        )
                      : _GridBody(
                          subject: _subjects.isEmpty
                              ? null
                              : _subjects[_selectedChip.clamp(
                                  0,
                                  _subjects.length - 1,
                                )],
                          onOpenPaper: _openPaper,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.layout,
    required this.onToggleLayout,
  });

  final PastExamsLayout layout;
  final VoidCallback onToggleLayout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأختبارات',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleDark,
                  ),
                ),
                Text(
                  'اختبارات السنوات السابقة',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: layout == PastExamsLayout.accordion
                ? 'عرض الشبكة'
                : 'عرض القائمة',
            onPressed: onToggleLayout,
            icon: Icon(
              layout == PastExamsLayout.accordion
                  ? Icons.grid_view_rounded
                  : Icons.view_agenda_outlined,
              color: AppColors.primary,
            ),
          ),
          Image.asset(
            'img_logo_btn.png'.image_,
            width: 45,
            height: 34,
            errorBuilder: (_, __, ___) => Text(
              'Falta',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccordionBody extends StatelessWidget {
  const _AccordionBody({
    required this.subjects,
    required this.onToggle,
    required this.onOpenPaper,
  });

  final List<PastExamSubjectEntity> subjects;
  final ValueChanged<String> onToggle;
  final ValueChanged<PastExamPaperEntity> onOpenPaper;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => onToggle(subject.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.name,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.titleDark,
                          ),
                        ),
                      ),
                      Icon(
                        subject.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (subject.isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < subject.papers.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => onOpenPaper(subject.papers[i]),
                          child: Text(
                            '${i + 1}- اختبار سنة  ${subject.papers[i].yearLabel}',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: i == 0
                                  ? AppColors.primary
                                  : AppColors.titleDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.subject,
    required this.onOpenPaper,
  });

  final PastExamSubjectEntity? subject;
  final ValueChanged<PastExamPaperEntity> onOpenPaper;

  @override
  Widget build(BuildContext context) {
    final papers = subject?.papers ?? const <PastExamPaperEntity>[];
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 80,
      ),
      itemCount: papers.length,
      itemBuilder: (context, i) {
        final paper = papers[i];
        return PastExamYearCard(
          paper: paper,
          onTap: () => onOpenPaper(paper),
        );
      },
    );
  }
}
