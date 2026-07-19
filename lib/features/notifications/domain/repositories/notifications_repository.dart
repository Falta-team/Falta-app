import 'package:falta_app/features/notifications/domain/entities/notifications_entity.dart';

/// Abstract contract for the Notifications feature.
///
/// The implementation lives in the data layer
/// (`notifications_repository_impl.dart`) and is the only
/// place allowed to know about the actual data source (API, local DB, etc).
abstract class NotificationsRepository {
  /// `GET /notifications` — requires a Bearer token.
  Future<List<NotificationsEntity>> getAll(String token);

  /// `PUT /notifications/{id}/read` — requires a Bearer token.
  Future<void> markRead(String id, String token);

  /// `PUT /notifications/read-all` — requires a Bearer token.
  Future<void> markAllRead(String token);

  /// `DELETE /notifications/{id}` — requires a Bearer token.
  Future<void> delete(String id, String token);
}
