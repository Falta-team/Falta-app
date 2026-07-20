import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';

/// A subject that has exam-attempt history.
class HistorySubjectEntity {
  const HistorySubjectEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.correctCount,
    required this.wrongCount,
  });

  final String id;
  final String name;
  final String image;
  final int correctCount;
  final int wrongCount;

  int get totalCount => correctCount + wrongCount;
}

/// Filter for the history detail screen.
enum HistoryQuestionFilter { correct, wrong }

/// Answered questions for one subject, with the user's selections preserved.
class HistoryRecordEntity {
  const HistoryRecordEntity({
    required this.subjectId,
    required this.subjectName,
    required this.questions,
  });

  final String subjectId;
  final String subjectName;
  final List<ExamQuestionEntity> questions;

  List<ExamQuestionEntity> filtered(HistoryQuestionFilter filter) {
    return questions.where((q) {
      if (filter == HistoryQuestionFilter.correct) return q.isCorrect;
      return q.isAnswered && !q.isCorrect;
    }).toList();
  }
}
