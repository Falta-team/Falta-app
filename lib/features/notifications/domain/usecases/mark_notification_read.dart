import 'package:falta_app/features/notifications/domain/repositories/notifications_repository.dart';

/// Use case that marks a single notification as read
/// (`PUT /notifications/{id}/read`).
class MarkNotificationRead {
  const MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  Future<void> call(String id, String token) {
    return _repository.markRead(id, token);
  }
}
