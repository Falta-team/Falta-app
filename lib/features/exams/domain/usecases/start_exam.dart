import 'package:falta_app/features/exams/domain/entities/exam_attempt_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

/// Use case that starts an exam attempt (`POST /exams/{examId}/start`,
/// requires a Bearer token) and returns the question set to answer.
class StartExam {
  const StartExam(this._repository);

  final ExamsRepository _repository;

  Future<ExamAttemptEntity> call({
    required String examId,
    required String token,
  }) {
    return _repository.startExam(examId: examId, token: token);
  }
}
