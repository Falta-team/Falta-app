import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';

/// Result of `POST /exams/{examId}/start`.
///
/// Holds the `attemptId` the app must send back on submit, plus the
/// question set for this attempt. Correct answers are **not** known at
/// this point — they're only revealed in the submit response — so every
/// [ExamQuestionEntity.options] here has `isCorrect: false` until the
/// exam is graded.
class ExamAttemptEntity {
  const ExamAttemptEntity({
    required this.attemptId,
    required this.examId,
    required this.timeLimitMinutes,
    required this.questions,
  });

  final String attemptId;
  final String examId;

  /// Duration for this attempt, in minutes (falls back to the parent
  /// exam's `timeLimit` if the start response doesn't repeat it).
  final int timeLimitMinutes;
  final List<ExamQuestionEntity> questions;
}
