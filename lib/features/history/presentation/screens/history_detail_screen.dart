import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/history/data/repositories/history_repository_impl.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';
import 'package:falta_app/features/history/domain/usecases/get_history_record.dart';
import 'package:falta_app/features/history/domain/usecases/get_history_subjects.dart';
import 'package:falta_app/features/history/presentation/widgets/history_filter_toggle.dart';
import 'package:falta_app/features/history/presentation/widgets/history_question_block.dart';
import 'package:falta_app/features/history/presentation/widgets/history_subject_strip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Per-subject exam history (Figma nodes 1:24280, 1:24406, 1:24539).
class HistoryDetailScreen extends StatefulWidget {
  const HistoryDetailScreen({
    required this.initialSubjectId,
    super.key,
  });

  static const String routeName = '/history-detail';

  final String initialSubjectId;

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late final HistoryRepositoryImpl _repository = HistoryRepositoryImpl();
  late final GetHistorySubjects _getSubjects = GetHistorySubjects(_repository);
  late final GetHistoryRecord _getRecord = GetHistoryRecord(_repository);

  List<HistorySubjectEntity> _subjects = const [];
  HistoryRecordEntity? _record;
  HistoryQuestionFilter _filter = HistoryQuestionFilter.correct;
  bool _loading = true;
  late String _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>([
      _getSubjects(),
      _getRecord(_selectedSubjectId),
    ]);
    if (!mounted) return;
    setState(() {
      _subjects = results[0] as List<HistorySubjectEntity>;
      _record = results[1] as HistoryRecordEntity;
      _loading = false;
    });
  }

  Future<void> _switchSubject(String subjectId) async {
    if (subjectId == _selectedSubjectId) return;
    setState(() {
      _selectedSubjectId = subjectId;
      _loading = true;
    });
    final record = await _getRecord(subjectId);
    if (!mounted) return;
    setState(() {
      _record = record;
      _loading = false;
    });
  }

  HistorySubjectEntity? get _currentSubject {
    for (final s in _subjects) {
      if (s.id == _selectedSubjectId) return s;
    }
    return _subjects.isNotEmpty ? _subjects.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final subject = _currentSubject;

    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: const ExamAppBar(title: 'السجل'),
      body: _loading || record == null || subject == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                HistorySubjectStrip(
                  subjects: _subjects,
                  selectedId: _selectedSubjectId,
                  onSelected: _switchSubject,
                ),
                const SizedBox(height: 20),
                HistoryFilterToggle(
                  filter: _filter,
                  correctCount: subject.correctCount,
                  wrongCount: subject.wrongCount,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildQuestionsList(record),
                ),
              ],
            ),
    );
  }

  Widget _buildQuestionsList(HistoryRecordEntity record) {
    final questions = record.filtered(_filter);
    if (questions.isEmpty) {
      return Center(
        child: Text(
          'لا توجد أسئلة',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        itemCount: questions.length,
        separatorBuilder: (_, __) => const Divider(
          height: 24,
          thickness: 1,
          color: Color(0xFFF0F0F0),
        ),
        itemBuilder: (context, index) {
          return HistoryQuestionBlock(question: questions[index]);
        },
      ),
    );
  }
}
