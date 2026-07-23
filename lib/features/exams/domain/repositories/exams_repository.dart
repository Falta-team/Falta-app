import 'package:falta_app/features/exams/domain/entities/exam_attempt_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';

/// Abstract contract for the (student-facing) live Exams feature.
///
/// The implementation lives in the data layer (`exams_repository_impl.dart`)
/// and is the only place allowed to know about the actual API shapes.
abstract class ExamsRepository {
  /// `GET /exams?subject=` (server-side filter when [subject] is set).
  Future<List<ExamsEntity>> getExams({String? subject});

  /// `GET /exams/{examId}` — exam metadata before starting.
  Future<ExamsEntity> getExamById(String examId);

  /// `POST /exams/{examId}/start` — requires a Bearer token. Returns the
  /// attempt id + question set the student will answer.
  Future<ExamAttemptEntity> startExam({
    required String examId,
    required String token,
  });

  /// `POST /exams/{attemptId}/answers` — autosave a single answer.
  Future<void> saveAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeTakenSeconds,
    required String token,
  });

  /// `GET /exams/{examId}/results/{attemptId}` — graded attempt details.
  Future<ExamResultEntity> getExamResult({
    required String examId,
    required String attemptId,
    required String token,
  });

  /// `POST /exams/{examId}/submit` — requires a Bearer token. Sends the
  /// student's answers and returns the graded result.
  Future<ExamResultEntity> submitExam({
    required String examId,
    required String attemptId,
    required int timeTakenSeconds,
    required List<ExamQuestionEntity> answeredQuestions,
    required String token,
    Map<String, String> correctAnswers = const {},
  });
}