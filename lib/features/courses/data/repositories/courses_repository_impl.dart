import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/courses/data/models/courses_model.dart';
import 'package:falta_app/features/courses/domain/entities/courses_entity.dart';
import 'package:falta_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:http/http.dart' as http;

/// Feature-specific exception carrying the API's Arabic `message` field.
class CoursesApiException implements Exception {
  const CoursesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Concrete implementation of [CoursesRepository].
///
/// Talks to the real Falta API using `http`, following the API
/// integration rules: parse every URI with [Uri.parse], attach the
/// correct headers, check status codes via [ApiSettings.isSuccess] /
/// [ApiSettings.isFailure], decode the JSON body, map it to
/// [CoursesModel], and throw a [CoursesApiException] on failure.
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl();

  @override
  Future<List<CoursesEntity>> getAllCourses() async {
    try {
      final uri = Uri.parse(ApiSettings.courses);
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(
          body,
        ).map((e) => CoursesModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      throw CoursesApiException(_extractMessage(body) ?? 'فشل تحميل الكورسات');
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<CoursesEntity> getCourseDetails(String id) async {
    try {
      final uri = Uri.parse(ApiSettings.courseById(id));
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        final data = _extractObject(body);
        return CoursesModel.fromJson(data);
      }

      throw CoursesApiException(
        _extractMessage(body) ?? 'فشل تحميل تفاصيل الكورس',
      );
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<List<CoursesEntity>> getCoursesBySubject(String subject) async {
    try {
      final uri = Uri.parse(ApiSettings.coursesBySubject(subject));
      final response = await http.get(uri, headers: ApiSettings.jsonHeaders);
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(
          body,
        ).map((e) => CoursesModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      throw CoursesApiException(
        _extractMessage(body) ?? 'فشل تحميل كورسات هذه المادة',
      );
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  @override
  Future<void> enrollCourse(String id, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.enrollCourse(id));
      final response = await http.post(
        uri,
        headers: ApiSettings.authHeaders(token),
      );

      if (ApiSettings.isSuccess(response.statusCode)) return;

      final dynamic body = jsonDecode(response.body);
      throw CoursesApiException(
        _extractMessage(body) ?? 'فشل التسجيل في الكورس',
      );
    } on CoursesApiException {
      rethrow;
    } catch (e) {
      throw CoursesApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  /// Confirmed real shape: `{ success, data: { courses: [...], pagination } }`.
  /// Falls back gracefully in case the backend ever changes the wrapper.
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic courses = data['courses'];
        if (courses is List) return courses;
      }
      if (data is List) return data;
      final dynamic coursesFlat = body['courses'];
      if (coursesFlat is List) return coursesFlat;
    }
    return const [];
  }

  /// The API may wrap a single object under `data` / `course`, or return
  /// it raw.
  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'] ?? body['course'];
      if (data is Map<String, dynamic>) return data;
      return body;
    }
    return const {};
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) return body['message'] as String?;
    return null;
  }
}