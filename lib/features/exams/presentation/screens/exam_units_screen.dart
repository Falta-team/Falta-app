import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:falta_app/features/exams/domain/entities/exam_unit_entity.dart';
import 'package:falta_app/features/exams/domain/usecases/get_exam_units.dart';
import 'package:falta_app/features/exams/presentation/screens/exam_session_screen.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_app_bar.dart';
import 'package:falta_app/features/exams/presentation/widgets/exam_unit_card.dart';
import 'package:falta_app/features/exams/presentation/widgets/semester_toggle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamUnitsScreen extends StatefulWidget {
  const ExamUnitsScreen({
    super.key,
    this.subjectTitle = 'الرياضيات',
  });

  static const String routeName = '/exam-units';

  final String subjectTitle;

  @override
  State<ExamUnitsScreen> createState() => _ExamUnitsScreenState();
}

class _ExamUnitsScreenState extends State<ExamUnitsScreen> {
  final GetExamUnits _getExamUnits = const GetExamUnits(ExamsRepositoryImpl());

  int _semester = 1;
  bool _loading = true;
  List<ExamUnitEntity> _units = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final units = await _getExamUnits(semester: _semester);
    if (!mounted) return;
    setState(() {
      _units = units;
      _loading = false;
    });
  }

  void _toggleExpand(String unitId) {
    setState(() {
      _units = _units
          .map(
            (u) => u.id == unitId ? u.copyWith(isExpanded: !u.isExpanded) : u,
          )
          .toList();
    });
  }

  void _toggleUnit(String unitId) {
    setState(() {
      _units = _units.map((u) {
        if (u.id != unitId) return u;
        final selected = !u.isSelected;
        return u.copyWith(
          isSelected: selected,
          lessons: u.lessons
              .map((l) => l.copyWith(isSelected: selected))
              .toList(),
        );
      }).toList();
    });
  }

  void _toggleLesson(String unitId, String lessonId) {
    setState(() {
      _units = _units.map((u) {
        if (u.id != unitId) return u;
        final lessons = u.lessons
            .map(
              (l) => l.id == lessonId
                  ? l.copyWith(isSelected: !l.isSelected)
                  : l,
            )
            .toList();
        final allSelected = lessons.every((l) => l.isSelected);
        return u.copyWith(lessons: lessons, isSelected: allSelected);
      }).toList();
    });
  }

  List<String> get _selectedLessonIds => _units
      .expand((u) => u.lessons)
      .where((l) => l.isSelected)
      .map((l) => l.id)
      .toList();

  Future<void> _startExam() async {
    final lessonIds = _selectedLessonIds;
    if (lessonIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر درساً واحداً على الأقل')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamSessionScreen(
          subjectTitle: widget.subjectTitle,
          lessonIds: lessonIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAppColor,
      appBar: ExamAppBar(title: widget.subjectTitle),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: SemesterToggle(
              selectedSemester: _semester,
              onChanged: (value) {
                _semester = value;
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _units.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final unit = _units[index];
                      return ExamUnitCard(
                        unit: unit,
                        onToggleExpand: () => _toggleExpand(unit.id),
                        onToggleUnit: () => _toggleUnit(unit.id),
                        onToggleLesson: (lessonId) =>
                            _toggleLesson(unit.id, lessonId),
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
                  onPressed: _startExam,
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
    );
  }
}
