import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:http/http.dart' as http;

class AiAskResult {
  const AiAskResult({
    required this.answer,
    this.sessionId,
  });

  final String answer;
  final String? sessionId;
}

class AiPerformanceResult {
  const AiPerformanceResult({
    required this.summary,
    this.weakTopics = const [],
    this.recommendations = const [],
  });

  final String summary;
  final List<String> weakTopics;
  final List<String> recommendations;
}

class AiRemoteDataSource {
  AiRemoteDataSource({SharedPrefController? pref})
      : _pref = pref ?? SharedPrefController();

  final SharedPrefController _pref;

  Future<AiAskResult> ask({
    required String question,
    String subject = 'math',
    String? sessionId,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'question': question,
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    };

    final response = await http.post(
      Uri.parse(ApiSettings.aiAsk),
      headers: ApiSettings.authHeaders(_pref.accessToken),
      body: jsonEncode(body),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل الاتصال بالمساعد');
    }
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final answer = data['answer'] as String? ??
        data['response'] as String? ??
        data['message'] as String? ??
        data['content'] as String? ??
        '';
    if (answer.isEmpty) {
      throw Exception('لم يتم استلام رد من المساعد');
    }
    return AiAskResult(
      answer: answer,
      sessionId: data['sessionId']?.toString(),
    );
  }

  Future<AiPerformanceResult> analyzePerformance(String attemptId) async {
    final response = await http.post(
      Uri.parse(ApiSettings.aiAnalyze),
      headers: ApiSettings.authHeaders(_pref.accessToken),
      body: jsonEncode({'attemptId': attemptId}),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل تحليل الأداء');
    }
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AiPerformanceResult(
      summary: data['summary'] as String? ??
          data['analysis'] as String? ??
          data['message'] as String? ??
          'تم تحليل أدائك.',
      weakTopics: _asStringList(data['weakTopics'] ?? data['weakAreas']),
      recommendations: _asStringList(
        data['recommendations'] ?? data['studyPlan'],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> generateQuestions({
    required String subject,
    required String topic,
    required int count,
    String difficultyLevel = 'medium',
    String? examId,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'topic': topic,
      'count': count,
      'difficultyLevel': difficultyLevel,
      if (examId != null && examId.isNotEmpty) 'examId': examId,
    };
    final response = await http.post(
      Uri.parse(ApiSettings.aiGenerateQuestions),
      headers: ApiSettings.authHeaders(_pref.accessToken),
      body: jsonEncode(body),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل توليد الأسئلة');
    }
    final data = json['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic>) {
      final list = data['questions'] as List<dynamic>? ?? const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (value is String && value.isNotEmpty) return [value];
    return const [];
  }
}
