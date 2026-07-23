import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:http/http.dart' as http;

/// Raw HTTP calls for the student-facing Exams feature. Returns decoded
/// JSON bodies — mapping to models/entities happens one layer up in
/// [ExamsRepositoryImpl], same split used by the `courses` feature.
class ExamsRemoteDataSource {
  const ExamsRemoteDataSource();

  // ── GET /exams?subject= ────────────────────────────────────────────────
  Future<dynamic> getExams({String? subject}) async {
    final uri = subject == null || subject.isEmpty
        ? Uri.parse(ApiSettings.exams)
        : ApiSettings.examsQuery(subject: subject);
    final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
    return _decode(response);
  }

  // ── GET /exams/{id} ────────────────────────────────────────────────────
  Future<dynamic> getExamById(String examId) async {
    final uri = Uri.parse(ApiSettings.examById(examId));
    final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
    return _decode(response);
  }

  // ── GET /exams/subject/{subject} ───────────────────────────────────────
  Future<dynamic> getExamsBySubjectPath(String subject) async {
    final uri = Uri.parse(ApiSettings.examsBySubject(subject));
    final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
    return _decode(response);
  }

  // ── POST /exams/{examId}/start ─────────────────────────────────────────
  Future<dynamic> startExam({
    required String examId,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.startExam(examId));
    final response = await http.post(uri, headers: ApiSettings.authHeaders(token));
    return _decode(response);
  }

  // ── POST /exams/{attemptId}/answers ────────────────────────────────────
  Future<dynamic> saveAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
    required int timeTakenSeconds,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.saveExamAnswer(attemptId));
    final response = await http.post(
      uri,
      headers: ApiSettings.authHeaders(token),
      body: jsonEncode({
        'questionId': questionId,
        'answer': answer,
        'timeTaken': timeTakenSeconds,
      }),
    );
    return _decode(response);
  }

  // ── GET /exams/{id}/results/{attemptId} ────────────────────────────────
  Future<dynamic> getExamResult({
    required String examId,
    required String attemptId,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.examResult(examId, attemptId));
    final response = await http.get(uri, headers: ApiSettings.authHeaders(token));
    return _decode(response);
  }

  // ── POST /exams/{examId}/submit ────────────────────────────────────────
  Future<dynamic> submitExam({
    required String examId,
    required String attemptId,
    required int timeTakenSeconds,
    required List<Map<String, String>> answers,
    required String token,
  }) async {
    final uri = Uri.parse(ApiSettings.submitExam(examId));
    final response = await http.post(
      uri,
      headers: ApiSettings.authHeaders(token),
      body: jsonEncode({
        'attemptId': attemptId,
        'timeTaken': timeTakenSeconds,
        'answers': answers,
      }),
    );
    return _decode(response);
  }

  /// Returns `{ 'body': decodedJson, 'statusCode': int }` so the
  /// repository can decide success/failure using [ApiSettings.isSuccess].
  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? const {} : jsonDecode(response.body);
    } on FormatException {
      body = const {};
    }
    return {'body': body, 'statusCode': response.statusCode};
  }
}
