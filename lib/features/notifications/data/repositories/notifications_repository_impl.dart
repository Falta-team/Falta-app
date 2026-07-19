import 'dart:convert';

import 'package:falta_app/core/api/api_settings.dart';
import 'package:falta_app/features/notifications/data/models/notifications_model.dart';
import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';
import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:http/http.dart' as http;

class NotificationsApiException implements Exception {
  const NotificationsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Concrete implementation of [NotificationsRepository], following the
/// same request/response-shape handling used in `CoursesRepositoryImpl`.
class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl();

  // ── GET /notifications ────────────────────────────────────────────────
  @override
  Future<List<NotificationsEntity>> getAll(String token) async {
    try {
      final uri = Uri.parse(ApiSettings.notifications);
      final response =
      await http.get(uri, headers: ApiSettings.authHeaders(token));
      final dynamic body = jsonDecode(response.body);

      if (ApiSettings.isSuccess(response.statusCode)) {
        return _extractList(body)
            .map((e) =>
            NotificationsModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw NotificationsApiException(
          _extractMessage(body) ?? 'فشل تحميل الإشعارات');
    } on NotificationsApiException {
      rethrow;
    } catch (e) {
      throw NotificationsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── PUT /notifications/{id}/read ─────────────────────────────────────
  @override
  Future<void> markRead(String id, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.markRead(id));
      final response =
      await http.put(uri, headers: ApiSettings.authHeaders(token));
      if (ApiSettings.isSuccess(response.statusCode)) return;

      final dynamic body = jsonDecode(response.body);
      throw NotificationsApiException(
          _extractMessage(body) ?? 'فشل تحديث حالة الإشعار');
    } on NotificationsApiException {
      rethrow;
    } catch (e) {
      throw NotificationsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── PUT /notifications/read-all ──────────────────────────────────────
  @override
  Future<void> markAllRead(String token) async {
    try {
      final uri = Uri.parse(ApiSettings.markAllRead);
      final response =
      await http.put(uri, headers: ApiSettings.authHeaders(token));
      if (ApiSettings.isSuccess(response.statusCode)) return;

      final dynamic body = jsonDecode(response.body);
      throw NotificationsApiException(
          _extractMessage(body) ?? 'فشل تحديث كل الإشعارات');
    } on NotificationsApiException {
      rethrow;
    } catch (e) {
      throw NotificationsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── DELETE /notifications/{id} ───────────────────────────────────────
  @override
  Future<void> delete(String id, String token) async {
    try {
      final uri = Uri.parse(ApiSettings.deleteNotification(id));
      final response =
      await http.delete(uri, headers: ApiSettings.authHeaders(token));
      if (ApiSettings.isSuccess(response.statusCode)) return;

      final dynamic body = jsonDecode(response.body);
      throw NotificationsApiException(
          _extractMessage(body) ?? 'فشل حذف الإشعار');
    } on NotificationsApiException {
      rethrow;
    } catch (e) {
      throw NotificationsApiException('خطأ في الاتصال: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  /// Handles `{ data: { notifications: [...] } }` / `{ data: [...] }` /
  /// `{ notifications: [...] }` / `[...]`.
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final dynamic data = body['data'];
      if (data is Map<String, dynamic>) {
        final dynamic notifications = data['notifications'];
        if (notifications is List) return notifications;
      }
      if (data is List) return data;
      final dynamic flat = body['notifications'];
      if (flat is List) return flat;
    }
    return const [];
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) return body['message'] as String?;
    return null;
  }
}
