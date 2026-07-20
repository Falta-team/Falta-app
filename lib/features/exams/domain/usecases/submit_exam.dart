import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';

class SubmitExam {
  const SubmitExam();

  ExamResultEntity call(List<ExamQuestionEntity> questions) {
    final score = questions.where((q) => q.isCorrect).length;
    final total = questions.length;
    final ratio = total == 0 ? 0.0 : score / total;
    final message = ratio >= 0.7
        ? 'أحسنت'
        : ratio >= 0.4
            ? 'جيد'
            : 'حاول مرة أخرى';

    return ExamResultEntity(
      score: score,
      total: total,
      message: message,
      questions: questions,
    );
  }
}
