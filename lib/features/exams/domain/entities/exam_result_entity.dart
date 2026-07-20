import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';

enum ExamResultFilter { all, correct, incorrect }

class ExamResultEntity {
  const ExamResultEntity({
    required this.score,
    required this.total,
    required this.message,
    required this.questions,
  });

  final int score;
  final int total;
  final String message;
  final List<ExamQuestionEntity> questions;

  List<ExamQuestionEntity> filtered(ExamResultFilter filter) {
    switch (filter) {
      case ExamResultFilter.all:
        return questions;
      case ExamResultFilter.correct:
        return questions.where((q) => q.isCorrect).toList();
      case ExamResultFilter.incorrect:
        return questions.where((q) => q.isAnswered && !q.isCorrect).toList();
    }
  }
}
