import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

/// Use case that submits the student's answers
/// (`POST /exams/{examId}/submit`, requires a Bearer token) and returns
/// the graded result.
class SubmitExam {
  const SubmitExam(this._repository);

  final ExamsRepository _repository;

  Future<ExamResultEntity> call({
    required String examId,
    required String attemptId,
    required int timeTakenSeconds,
    required List<ExamQuestionEntity> answeredQuestions,
    required String token,
  }) {
    return _repository.submitExam(
      examId: examId,
      attemptId: attemptId,
      timeTakenSeconds: timeTakenSeconds,
      answeredQuestions: answeredQuestions,
      token: token,
    );
  }
}
