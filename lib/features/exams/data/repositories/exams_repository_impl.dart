import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/exams/data/models/exam_attempt_model.dart';
import 'package:falta_app/features/exams/data/models/exam_result_model.dart';
import 'package:falta_app/features/exams/data/models/exams_model.dart';
import 'package:falta_app/features/exams/data/sources/exams_remote_data_source.dart';
import 'package:falta_app/features/exams/domain/entities/exam_attempt_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_question_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exam_result_entity.dart';
import 'package:falta_app/features/exams/domain/entities/exams_entity.dart';
import 'package:falta_app/features/exams/domain/repositories/exams_repository.dart';

class ExamsApiException implements Exception {
  const ExamsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ExamsRepositoryImpl implements ExamsRepository {
  const ExamsRepositoryImpl({
    this.remote = const ExamsRemoteDataSource(),
  });

  final ExamsRemoteDataSource remote;

  // ── GET /exams?subject= ────────────────────────────────────────────────
  @override
  Future<List<ExamsEntity>> getExams({String? subject}) async {
    try {
      final result = await remote.getExams(subject: subject) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'فشل تحميل الاختبارات');
      }

      return _extractList(body)
          .map((e) => ExamsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── GET /exams/{id} ────────────────────────────────────────────────────
  @override
  Future<ExamsEntity> getExamById(String examId) async {
    try {
      final result = await remote.getExamById(examId) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'فشل تحميل الاختبار');
      }

      final data = _extractObject(body);
      final exam = data['exam'] is Map<String, dynamic>
          ? data['exam'] as Map<String, dynamic>
          : data;
      return ExamsModel.fromJson(exam);
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── POST /exams/{attemptId}/answers ────────────────────────────────────
  @override
  Future<void> saveAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeTakenSeconds,
    required String token,
  }) async {
    try {
      final result = await remote.saveAnswer(
        attemptId: attemptId,
        questionId: questionId,
        answer: answer,
        timeTakenSeconds: timeTakenSeconds,
        token: token,
      ) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'تعذر حفظ الإجابة');
      }
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── GET /exams/{id}/results/{attemptId} ────────────────────────────────
  @override
  Future<ExamResultEntity> getExamResult({
    required String examId,
    required String attemptId,
    required String token,
  }) async {
    try {
      final result = await remote.getExamResult(
        examId: examId,
        attemptId: attemptId,
        token: token,
      ) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'فشل تحميل النتيجة');
      }

      final resultData = _extractResultObject(body);
      return ExamResultModel.fromJson(
        resultData,
        answeredQuestions: const [],
      );
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── POST /exams/{examId}/start ─────────────────────────────────────────
  @override
  Future<ExamAttemptEntity> startExam({
    required String examId,
    required String token,
  }) async {
    try {
      final result = await remote.startExam(examId: examId, token: token)
      as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'تعذر بدء الاختبار');
      }

      // استخرج timeLimit من exam object في الـ response مباشرة
      final rawData    = (body is Map) ? (body['data'] as Map<String, dynamic>? ?? {}) : <String,dynamic>{};
      final examObj    = rawData['exam'] as Map<String, dynamic>? ?? {};
      final apiTimeLimit = (examObj['timeLimit'] as num?)?.toInt() ??
          (examObj['timeLimitMinutes'] as num?)?.toInt() ??
          0;

      return ExamAttemptModel.fromJson(
        _extractAttemptObject(body, examId: examId),
        fallbackExamId: examId,
        fallbackTimeLimitMinutes: apiTimeLimit > 0 ? apiTimeLimit : 40,
      );
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── POST /exams/{examId}/submit ────────────────────────────────────────
  @override
  Future<ExamResultEntity> submitExam({
    required String examId,
    required String attemptId,
    required int timeTakenSeconds,
    required List<ExamQuestionEntity> answeredQuestions,
    required String token,
    Map<String, String> correctAnswers = const {},
  }) async {
    try {
      final answers = [
        for (final q in answeredQuestions)
          if (q.selectedOptionId != null)
            {'questionId': q.id, 'answer': q.selectedOptionId!},
      ];

      final result = await remote.submitExam(
        examId: examId,
        attemptId: attemptId,
        timeTakenSeconds: timeTakenSeconds,
        answers: answers,
        token: token,
      ) as Map<String, dynamic>;
      final statusCode = result['statusCode'] as int;
      final body = result['body'];

      if (!ApiSettings.isSuccess(statusCode)) {
        throw ExamsApiException(_extractMessage(body) ?? 'تعذر تسليم الاختبار');
      }

      final resultData = _extractResultObject(body);
      return ExamResultModel.fromJson(
        resultData,
        answeredQuestions: answeredQuestions,
      );
    } on ExamsApiException {
      rethrow;
    } catch (e) {
      throw ExamsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Response-shape helpers ─────────────────────────────────────────────
  // The API wraps payloads as `{ data: { exams: [...] } }` (confirmed
  // shape for `courses`/`videos` on this backend) — handled defensively
  // here in case `exams` ever returns a bare list/object instead.

  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic exams = data['exams'];
        if (exams is List) return exams;
      }
      if (data is List) return data;
      final dynamic flat = body['exams'];
      if (flat is List) return flat;
    }
    return const [];
  }

  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return const {};
  }

  /// للـ start exam:
  /// { data: { attempt: {id,...}, exam: {timeLimit,...}, questions: [...], timeLimitMinutes: 20 } }
  Map<String, dynamic> _extractAttemptObject(dynamic body, {required String examId}) {
    if (body is! Map<String, dynamic>) return const {};
    final data = body['data'] as Map<String, dynamic>? ?? body;

    final attempt     = data['attempt']     as Map<String, dynamic>? ?? {};
    final exam        = data['exam']        as Map<String, dynamic>? ?? {};
    final questions   = data['questions']   // ← الأسئلة في data مباشرة
        ?? attempt['questions']
        ?? exam['questions'];
    final timeLimit   = data['timeLimitMinutes']  // ← في data مباشرة
        ?? attempt['timeLimitMinutes']
        ?? attempt['timeLimit']
        ?? exam['timeLimit']
        ?? exam['timeLimitMinutes'];
    final attemptId   = attempt['id']
        ?? attempt['attemptId']
        ?? data['attemptId'];

    return {
      ...attempt,                       // id, startTime, ...
      'attemptId': attemptId,          // نضمن وجوده بالاسمين
      if (questions != null) 'questions': questions,
      if (timeLimit != null) 'timeLimit': timeLimit,
    };
  }

  /// للـ submit exam: { data: { score, total, results, attempt: {...} } }
  Map<String, dynamic> _extractResultObject(dynamic body) {
    if (body is! Map<String, dynamic>) return const {};
    final data = body['data'] as Map<String, dynamic>? ?? body;

    // لو النتيجة داخل attempt
    final attempt = data['attempt'] as Map<String, dynamic>?;
    if (attempt != null) {
      return {
        ...data,
        ...attempt,
      };
    }
    return data;
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      return body['message'] as String?;
    }
    return null;
  }
}