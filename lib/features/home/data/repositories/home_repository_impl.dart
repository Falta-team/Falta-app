import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/home/data/models/home_model.dart';
import 'package:falta_app/features/home/domain/entities/home_entity.dart';
import 'package:falta_app/features/home/domain/repositories/home_repository.dart';
import 'package:http/http.dart' as http;

/// Feature-specific exception carrying the API's Arabic `message` field.
class HomeApiException implements Exception {
  const HomeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Concrete implementation of [HomeRepository].
///
/// There is no dedicated `/home` endpoint, so this repository composes
/// the dashboard from three existing endpoints, calling all of them in
/// parallel via [Future.wait]. Each individual call still checks its own
/// status code and decodes independently before the results are merged.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<HomeEntity> getHomeDashboard({required String token}) async {
    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(ApiSettings.profile),
          headers: ApiSettings.authHeaders(token),
        ),
        http.get(
          Uri.parse(ApiSettings.courses),
          headers: ApiSettings.jsonHeaders,
        ),
        http.get(
          Uri.parse(ApiSettings.subscriptionStatus),
          headers: ApiSettings.authHeaders(token),
        ),
      ]);

      final profileResponse = responses[0];
      final coursesResponse = responses[1];
      final subscriptionResponse = responses[2];

      // ── Profile (required) ────────────────────────────────────────────
      if (!ApiSettings.isSuccess(profileResponse.statusCode)) {
        throw HomeApiException(
          _extractMessage(_tryDecode(profileResponse.body)) ??
              'فشل تحميل بيانات الملف الشخصي',
        );
      }
      final profileJson = jsonDecode(profileResponse.body) as Map<String, dynamic>;

      // ── Courses (required) ─────────────────────────────────────────────
      if (!ApiSettings.isSuccess(coursesResponse.statusCode)) {
        throw HomeApiException(
          _extractMessage(_tryDecode(coursesResponse.body)) ??
              'فشل تحميل الكورسات',
        );
      }
      final dynamic coursesBody = jsonDecode(coursesResponse.body);
      final List<dynamic> coursesJson = coursesBody is Map<String, dynamic>
          ? ((coursesBody['data'] ?? coursesBody['courses'] ?? const [])
              as List<dynamic>)
          : (coursesBody as List<dynamic>);

      // ── Subscription (optional badge — tolerate failure) ───────────────
      Map<String, dynamic>? subscriptionJson;
      if (ApiSettings.isSuccess(subscriptionResponse.statusCode)) {
        final dynamic decoded = _tryDecode(subscriptionResponse.body);
        if (decoded is Map<String, dynamic>) subscriptionJson = decoded;
      }

      return HomeModel.fromResponses(
        profileJson: profileJson,
        coursesJson: coursesJson,
        subscriptionJson: subscriptionJson,
      );
    } on HomeApiException {
      rethrow;
    } catch (e) {
      throw HomeApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
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
