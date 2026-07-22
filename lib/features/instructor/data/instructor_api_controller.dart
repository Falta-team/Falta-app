import 'dart:convert';
import 'dart:io';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/core/pref/shared_pref_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Instructor / content-creator API calls.
class InstructorApiController {
  InstructorApiController({SharedPrefController? pref})
      : _pref = pref ?? SharedPrefController();

  final SharedPrefController _pref;

  Map<String, String> get _headers =>
      ApiSettings.authHeaders(_pref.accessToken);

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String subject,
    required String description,
    required String academicTrack,
    required String difficultyLevel,
    String? instructorId,
  }) async {
    final response = await http.post(
      Uri.parse(ApiSettings.courses),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'subject': subject,
        'description': description,
        'academicTrack': academicTrack,
        'difficultyLevel': difficultyLevel,
        if (instructorId != null && instructorId.isNotEmpty)
          'instructorId': instructorId,
      }),
    );
    return _decode(response, 'فشل إنشاء الكورس');
  }

  Future<List<Map<String, dynamic>>> listInstructors() async {
    final response = await http.get(
      Uri.parse(ApiSettings.instructors),
      headers: ApiSettings.jsonHeaders,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل جلب المدرّسين');
    }
    final data = json['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final list = data['instructors'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> createInstructor({
    required String fullName,
    required String credentials,
    required String expertiseAreas,
    required String biography,
  }) async {
    final response = await http.post(
      Uri.parse(ApiSettings.instructors),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'credentials': credentials,
        'expertiseAreas': expertiseAreas,
        'biography': biography,
      }),
    );
    return _decode(response, 'فشل إنشاء المدرّس');
  }

  Future<Map<String, dynamic>> createExam({
    required String title,
    required String subject,
    required int durationMinutes,
    required int questionCount,
    String year = '2025/2026',
    String academicTrack = 'scientific',
    String difficultyLevel = 'medium',
  }) async {
    final response = await http.post(
      Uri.parse(ApiSettings.exams),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'subject': subject,
        'year': year,
        'academicTrack': academicTrack,
        'totalQuestions': questionCount,
        'timeLimit': durationMinutes,
        'difficultyLevel': difficultyLevel,
      }),
    );
    return _decode(response, 'فشل إنشاء الامتحان');
  }

  Future<Map<String, dynamic>> addExamQuestion({
    required String examId,
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
    String? explanation,
    String? topicTag,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiSettings.exams}/$examId/questions'),
      headers: _headers,
      body: jsonEncode({
        'questionText': questionText,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctAnswer': correctAnswer,
        if (explanation != null && explanation.isNotEmpty)
          'explanation': explanation,
        if (topicTag != null && topicTag.isNotEmpty) 'topicTag': topicTag,
      }),
    );
    return _decode(response, 'فشل إضافة السؤال');
  }

  Future<Map<String, dynamic>> uploadVideo({
    required String courseId,
    required String title,
    required int sequenceOrder,
    required File file,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiSettings.videos}/upload'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer ${_pref.accessToken}',
      'Accept': 'application/json',
    });
    request.fields['courseId'] = courseId;
    request.fields['title'] = title;
    request.fields['sequenceOrder'] = '$sequenceOrder';

    final filename = file.path.split(Platform.pathSeparator).last;
    final ext = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    final mime = switch (ext) {
      'mp4' => MediaType('video', 'mp4'),
      'mov' => MediaType('video', 'quicktime'),
      'webm' => MediaType('video', 'webm'),
      _ => MediaType('application', 'octet-stream'),
    };
    request.files.add(
      await http.MultipartFile.fromPath(
        'video',
        file.path,
        filename: filename,
        contentType: mime,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response, 'فشل رفع الفيديو');
  }

  Future<Map<String, dynamic>> getCourseProgress(String courseId) async {
    final response = await http.get(
      Uri.parse(ApiSettings.courseProgress(courseId)),
      headers: _headers,
    );
    return _decode(response, 'فشل جلب التقدم');
  }

  Future<void> recordVideoView(String videoId) async {
    final response = await http.post(
      Uri.parse(ApiSettings.recordVideoView(videoId)),
      headers: _headers,
    );
    if (!ApiSettings.isSuccess(response.statusCode)) {
      // Non-blocking for playback UX
      return;
    }
  }

  /// Prefers stream endpoint URL when available; falls back to [fallbackUrl].
  Future<String> resolvePlayableUrl({
    required String videoId,
    required String fallbackUrl,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiSettings.videoStream(videoId)),
        headers: _headers,
      );
      if (!ApiSettings.isSuccess(response.statusCode)) return fallbackUrl;
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic>) {
        final data = json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;
        final url = data['streamUrl']?.toString() ??
            data['url']?.toString() ??
            data['videoUrl']?.toString();
        if (url != null && url.isNotEmpty) return url;
      }
    } catch (_) {}
    return fallbackUrl;
  }

  Future<List<Map<String, dynamic>>> listCourses() async {
    final response = await http.get(
      Uri.parse(ApiSettings.courses),
      headers: ApiSettings.jsonHeaders,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل جلب الكورسات');
    }
    final data = json['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final list = data['courses'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> listExams() async {
    final response = await http.get(
      Uri.parse(ApiSettings.exams),
      headers: _headers,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      throw Exception(json['message'] as String? ?? 'فشل جلب الامتحانات');
    }
    final data = json['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final list = data['exams'] as List<dynamic>? ??
          data['items'] as List<dynamic>? ??
          const [];
      return list.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> _decode(
    http.Response response,
    String fallback,
  ) async {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!ApiSettings.isSuccess(response.statusCode)) {
      final error = json['error'];
      final msg = json['message'] as String? ??
          (error is Map ? error['message'] as String? : null) ??
          fallback;
      throw Exception(msg);
    }
    return json['data'] as Map<String, dynamic>? ?? json;
  }
}
