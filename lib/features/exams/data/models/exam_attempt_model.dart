import 'package:falta_app/features/exams/data/models/exam_question_model.dart';
import 'package:falta_app/features/exams/domain/entities/exam_attempt_entity.dart';

/// Parses `POST /exams/{examId}/start`.
///
/// Expected shape (mirrors the `{ data: { ... } }` envelope already
/// confirmed for `courses`/`videos` on this API):
/// `{ data: { attemptId, examId, timeLimit, questions: [...] } }`.
class ExamAttemptModel extends ExamAttemptEntity {
  const ExamAttemptModel({
    required super.attemptId,
    required super.examId,
    required super.timeLimitMinutes,
    required super.questions,
  });

  factory ExamAttemptModel.fromJson(
      Map<String, dynamic> json, {
        required String fallbackExamId,
        required int fallbackTimeLimitMinutes,
      }) {
    final questionsJson = json['questions'] as List<dynamic>? ?? <dynamic>[];
    return ExamAttemptModel(
      attemptId: json['attemptId']?.toString() ??
          json['id']?.toString()   ??
          '',
      examId: json['examId']?.toString() ?? fallbackExamId,
      timeLimitMinutes:
      (json['timeLimit']         as num?)?.toInt() ??
          (json['timeLimitMinutes']  as num?)?.toInt() ??
          (json['time_limit']        as num?)?.toInt() ??
          fallbackTimeLimitMinutes,
      questions: questionsJson
          .map((e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}