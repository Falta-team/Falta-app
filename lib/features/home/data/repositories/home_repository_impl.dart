import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/home/data/models/home_model.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';
import 'package:http/http.dart' as http;

class HomeApiException implements Exception {
  const HomeApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<HomeEntity> getHomeDashboard({required String token}) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(ApiSettings.profile),
            headers: ApiSettings.authHeaders(token)),
        http.get(Uri.parse(ApiSettings.courses),
            headers: ApiSettings.jsonHeaders),
        http.get(Uri.parse(ApiSettings.subscriptionStatus),
            headers: ApiSettings.authHeaders(token)),
      ]);

      final profileResponse      = responses[0];
      final coursesResponse      = responses[1];
      final subscriptionResponse = responses[2];

      // ── Profile (required) ────────────────────────────────────────────
      if (!ApiSettings.isSuccess(profileResponse.statusCode)) {
        throw HomeApiException(
          _extractMessage(_tryDecode(profileResponse.body)) ??
              'فشل تحميل بيانات الملف الشخصي',
        );
      }
      final profileJson =
      jsonDecode(profileResponse.body) as Map<String, dynamic>;

      // ── Courses (required) ────────────────────────────────────────────
      if (!ApiSettings.isSuccess(coursesResponse.statusCode)) {
        throw HomeApiException(
          _extractMessage(_tryDecode(coursesResponse.body)) ??
              'فشل تحميل الكورسات',
        );
      }
      final dynamic coursesRaw = jsonDecode(coursesResponse.body);

      // ✅ FIX: API shape is { data: { courses: [...] } }
      // _extractCoursesList handles all nesting variants safely.
      final List<dynamic> coursesJson = _extractCoursesList(coursesRaw);

      // ── Subscription (optional — tolerate failure) ────────────────────
      Map<String, dynamic>? subscriptionJson;
      if (ApiSettings.isSuccess(subscriptionResponse.statusCode)) {
        final dynamic decoded = _tryDecode(subscriptionResponse.body);
        if (decoded is Map<String, dynamic>) subscriptionJson = decoded;
      }

      return HomeModel.fromResponses(
        profileJson:      profileJson,
        coursesJson:      coursesJson,
        subscriptionJson: subscriptionJson,
      );
    } on HomeApiException {
      rethrow;
    } catch (e) {
      throw HomeApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Safely extracts the courses list from any API wrapper shape:
  /// - `{ data: { courses: [...] } }`   ← confirmed real shape
  /// - `{ data: [...] }`
  /// - `{ courses: [...] }`
  /// - `[...]`   (raw array)
  List<dynamic> _extractCoursesList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      // { data: { courses: [...] } }
      if (data is Map<String, dynamic>) {
        final dynamic courses = data['courses'];
        if (courses is List) return courses;
      }
      // { data: [...] }
      if (data is List) return data;
      // { courses: [...] }
      final dynamic flat = body['courses'];
      if (flat is List) return flat;
    }
    return const [];
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) return body['message'] as String?;
    return null;
  }
}