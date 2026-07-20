import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/history/domain/entities/history_entities.dart';

/// Mock history data until the `examHistory` API is wired up.
class HistoryLocalDataSource {
  static const List<HistorySubjectEntity> _subjects = [
    HistorySubjectEntity(
      id: 'math',
      name: 'الرياضيات',
      image: 'math',
      correctCount: 54,
      wrongCount: 87,
    ),
    HistorySubjectEntity(
      id: 'physics',
      name: 'الفيزياء',
      image: 'physics',
      correctCount: 32,
      wrongCount: 45,
    ),
    HistorySubjectEntity(
      id: 'chemistry',
      name: 'الكيمياء',
      image: 'chemistry',
      correctCount: 28,
      wrongCount: 19,
    ),
    HistorySubjectEntity(
      id: 'biology',
      name: 'العلوم الحياتية',
      image: 'arabic',
      correctCount: 41,
      wrongCount: 22,
    ),
    HistorySubjectEntity(
      id: 'arabic',
      name: 'لغة عربية',
      image: 'arabic',
      correctCount: 60,
      wrongCount: 15,
    ),
  ];

  Future<List<HistorySubjectEntity>> fetchSubjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _subjects;
  }

  Future<HistoryRecordEntity> fetchRecord(String subjectId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final subject = _subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => _subjects.first,
    );
    return HistoryRecordEntity(
      subjectId: subject.id,
      subjectName: subject.name,
      questions: _buildQuestions(subject.id),
    );
  }

  List<ExamQuestionEntity> _buildQuestions(String subjectId) {
    const template = 'أي الآتية ليست من خصائص الكودون:';
    const options = [
      ExamOptionEntity(id: 'a', text: 'يمكن أن يشفر أكثر من حمض أميني.', isCorrect: true),
      ExamOptionEntity(id: 'b', text: 'يتكون من ثلاثة nucleotides.', isCorrect: false),
      ExamOptionEntity(id: 'c', text: 'يقرأ باتجاه 5\' إلى 3\'.', isCorrect: false),
      ExamOptionEntity(id: 'd', text: 'يوجد على mRNA.', isCorrect: false),
    ];

    return List<ExamQuestionEntity>.generate(6, (i) {
      final index = i + 1;
      // Mix of correct and wrong answers for demo.
      final selected = switch (i % 3) {
        0 => 'a',
        1 => 'b',
        _ => 'c',
      };
      return ExamQuestionEntity(
        id: '$subjectId-q$index',
        text: '$index- $template',
        options: options,
        selectedOptionId: selected,
      );
    });
  }
}
