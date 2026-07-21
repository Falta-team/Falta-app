import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:http/http.dart' as http;

/// Raw HTTP calls for the student-facing Exams feature. Returns decoded
/// JSON bodies — mapping to models/entities happens one layer up in
/// [ExamsRepositoryImpl], same split used by the `courses` feature.
class ExamsRemoteDataSource {
  const ExamsRemoteDataSource();

  // ── GET /exams ──────────────────────────────────────────────────────────
  Future<dynamic> getExams() async {
    final uri = Uri.parse(ApiSettings.exams);
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
